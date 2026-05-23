import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';
import '../models/task_item.dart';

class DatabaseService {
  // Private singleton constructor
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get path to local system application documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'retivy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table 1: Habits
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        iconName TEXT NOT NULL,
        colorKey TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        isSkipped INTEGER NOT NULL,
        skipReason TEXT,
        currentValue REAL NOT NULL,
        targetValue REAL NOT NULL,
        unit TEXT NOT NULL,
        stepValue REAL NOT NULL,
        totalSeconds INTEGER NOT NULL,
        remainingSeconds INTEGER NOT NULL,
        isRunning INTEGER NOT NULL
      )
    ''');

    // Table 2: Tasks
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');

    // Table 3: Time blocks
    await db.execute('''
      CREATE TABLE timeblocks(
        hour TEXT PRIMARY KEY,
        taskId TEXT
      )
    ''');

    // Table 4: User RPG Stats
    await db.execute('''
      CREATE TABLE user_stats(
        key TEXT PRIMARY KEY,
        value INTEGER NOT NULL
      )
    ''');
  }

  // --- HABITS CRUD ---

  Future<void> saveHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> fetchHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  // --- TASKS CRUD ---

  Future<void> saveTask(TaskItem task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskItem>> fetchTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => TaskItem.fromMap(maps[i]));
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Also delete any timeblock references to this task
    await db.update(
      'timeblocks',
      {'taskId': null},
      where: 'taskId = ?',
      whereArgs: [id],
    );
  }

  // --- TIMEBLOCKS CRUD ---

  Future<void> saveTimeblocks(Map<String, String?> timeblocks) async {
    final db = await database;
    final batch = db.batch();
    timeblocks.forEach((hour, taskId) {
      batch.insert(
        'timeblocks',
        {
          'hour': hour,
          'taskId': taskId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  Future<Map<String, String?>> fetchTimeblocks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('timeblocks');
    final Map<String, String?> timeblocks = {};
    for (final row in maps) {
      timeblocks[row['hour'] as String] = row['taskId'] as String?;
    }
    return timeblocks;
  }

  // --- USER RPG STATS ---

  Future<void> saveUserStat(String key, int value) async {
    final db = await database;
    await db.insert(
      'user_stats',
      {
        'key': key,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> fetchUserStat(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_stats',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as int;
  }

  // --- DATABASE UTILITIES ---

  Future<void> resetDatabase(List<Habit> defaultHabits, List<TaskItem> defaultTasks) async {
    final db = await database;
    
    // Clear all tables
    await db.delete('habits');
    await db.delete('tasks');
    await db.delete('timeblocks');
    await db.delete('user_stats');

    // Populate with defaults
    final batch = db.batch();
    for (final habit in defaultHabits) {
      batch.insert('habits', habit.toMap());
    }
    for (final task in defaultTasks) {
      batch.insert('tasks', task.toMap());
    }
    
    // Write defaults for RPG level & XP
    batch.insert('user_stats', {'key': 'level', 'value': 1});
    batch.insert('user_stats', {'key': 'xp', 'value': 0});

    await batch.commit(noResult: true);
  }

  // --- BACKUP & RESTORE UTILITIES ---

  Future<String> exportBackupAsJson() async {
    final habits = await fetchHabits();
    final tasks = await fetchTasks();
    final timeblocks = await fetchTimeblocks();
    final level = await fetchUserStat('level') ?? 2;
    final xp = await fetchUserStat('xp') ?? 180;

    final backupMap = {
      'habits': habits.map((h) => h.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'timeblocks': timeblocks,
      'stats': {
        'level': level,
        'xp': xp,
      }
    };

    final jsonStr = jsonEncode(backupMap);
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final backupFile = File(join(documentsDirectory.path, 'retivy_backup.json'));
    await backupFile.writeAsString(jsonStr);
    return backupFile.path;
  }

  Future<bool> importBackupFromJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      final jsonStr = await file.readAsString();
      final backupMap = jsonDecode(jsonStr) as Map<String, dynamic>;

      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('habits');
        await txn.delete('tasks');
        await txn.delete('timeblocks');
        await txn.delete('user_stats');

        final habitsList = backupMap['habits'] as List;
        for (final h in habitsList) {
          await txn.insert('habits', h as Map<String, dynamic>);
        }

        final tasksList = backupMap['tasks'] as List;
        for (final t in tasksList) {
          await txn.insert('tasks', t as Map<String, dynamic>);
        }

        final timeblocksMap = backupMap['timeblocks'] as Map<String, dynamic>;
        timeblocksMap.forEach((hour, taskId) async {
          await txn.insert('timeblocks', {
            'hour': hour,
            'taskId': taskId,
          });
        });

        final stats = backupMap['stats'] as Map<String, dynamic>;
        await txn.insert('user_stats', {'key': 'level', 'value': stats['level'] as int});
        await txn.insert('user_stats', {'key': 'xp', 'value': stats['xp'] as int});
      });

      return true;
    } catch (_) {
      return false;
    }
  }
}
