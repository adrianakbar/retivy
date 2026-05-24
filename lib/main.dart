import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/habit.dart';
import 'models/task_item.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'services/biometric_service.dart';
import 'screens/biometric_lock_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;
  UserSession? _currentUser;
  bool _isBiometricUnlocked = false;

  int _xp = 0;
  int _level = 1;

  late List<Habit> _habits;
  late List<TaskItem> _tasks;
  late Map<String, TaskItem?> _timeblocks;

  // Default seed data for the first launch (empty for clean user entry)
  static final List<Habit> _defaultHabits = [];

  static final List<TaskItem> _defaultTasks = [];

  @override
  void initState() {
    super.initState();
    _loadDatabase();
    AuthService.instance.authStateChanges.listen((session) {
      if (mounted) {
        setState(() {
          _currentUser = session;
          if (session == null) {
            _isBiometricUnlocked = false;
          } else {
            _isBiometricUnlocked = true;
          }
        });
      }
    });
  }

  Future<void> _loadDatabase() async {
    final dbService = DatabaseService.instance;
    await AuthService.instance.init();
    await NotificationService.instance.init();
    final currentSession = AuthService.instance.currentUserValue;

    // Fetch habits, tasks, userstats, and timeblocks from SQLite
    List<Habit> loadedHabits = await dbService.fetchHabits();
    List<TaskItem> loadedTasks = await dbService.fetchTasks();
    Map<String, String?> loadedTimeblockIds = await dbService.fetchTimeblocks();
    int? loadedLevel = await dbService.fetchUserStat('level');
    int? loadedXP = await dbService.fetchUserStat('xp');

    // First launch seeding or automatic migration to a clean slate from old seed data
    if (loadedLevel == null || (loadedLevel == 2 && loadedXP == 180)) {
      await dbService.resetDatabase(_defaultHabits, _defaultTasks);
      loadedHabits = await dbService.fetchHabits();
      loadedTasks = await dbService.fetchTasks();
      loadedTimeblockIds = await dbService.fetchTimeblocks();
      loadedLevel = 1;
      loadedXP = 0;
    }

    final Map<String, TaskItem?> mappedTimeblocks = {
      '07:00 AM': null,
      '09:00 AM': null,
      '12:00 PM': null,
      '03:00 PM': null,
      '06:00 PM': null,
      '08:00 PM': null,
    };

    // If timeblocks mapping is completely empty, seed default clean template
    if (loadedTimeblockIds.isEmpty) {
      final defaultMapping = {
        '07:00 AM': null,
        '09:00 AM': null,
        '12:00 PM': null,
        '03:00 PM': null,
        '06:00 PM': null,
        '08:00 PM': null,
      };
      await dbService.saveTimeblocks(defaultMapping);
      loadedTimeblockIds = defaultMapping;
    }

    loadedTimeblockIds.forEach((hour, taskId) {
      if (taskId != null) {
        final task = loadedTasks.where((t) => t.id == taskId).firstOrNull;
        mappedTimeblocks[hour] = task;
      } else {
        mappedTimeblocks[hour] = null;
      }
    });

    final isBiometricActive = await BiometricService.instance.isBiometricEnabled();
    final pendingTasksCount = loadedTasks.where((t) => !t.isCompleted).length;
    await NotificationService.instance.scheduleSmartReminder(pendingTasksCount);

    setState(() {
      _habits = loadedHabits;
      _tasks = loadedTasks;
      _timeblocks = mappedTimeblocks;
      _level = loadedLevel ?? 1;
      _xp = loadedXP ?? 0;
      _currentUser = currentSession;
      _isBiometricUnlocked = !isBiometricActive || currentSession == null;
      _isLoading = false;
    });
  }

  void _awardXP(int amount) {
    setState(() {
      _xp += amount;
      final targetXP = _level * 200;
      if (_xp >= targetXP) {
        _xp -= targetXP;
        _level += 1;

        // Custom Level Up Banner
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 4),
            content: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4648D4), Color(0xFF825100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: const [
                            Icon(LucideIcons.trophy, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Congratulations ${_currentUser?.name ?? 'Adrian'}! You reached Level $_level!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Dynamic floating XP gains with Lucide icon
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.award, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '+$amount XP earned! Target progress: $_xp / $targetXP',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Persist Stats
      DatabaseService.instance.saveUserStat('level', _level);
      DatabaseService.instance.saveUserStat('xp', _xp);
    });
  }

  void _updateHabit(Habit updatedHabit) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        final oldHabit = _habits[index];
        if (updatedHabit.isCompleted && !oldHabit.isCompleted) {
          _awardXP(50);
        }
        _habits[index] = updatedHabit;
        DatabaseService.instance.saveHabit(updatedHabit);
      }
    });
  }

  void _addHabit(Habit newHabit) {
    setState(() {
      _habits.add(newHabit);
      DatabaseService.instance.saveHabit(newHabit);
      _awardXP(20);
    });
  }

  void _resetAllHabits() {
    setState(() {
      _isLoading = true;
    });
    DatabaseService.instance.resetDatabase(_defaultHabits, _defaultTasks).then((_) {
      _loadDatabase();
    });
  }

  void _addTask(TaskItem newTask) {
    setState(() {
      _tasks.add(newTask);
      DatabaseService.instance.saveTask(newTask);
      _awardXP(20);
    });
    NotificationService.instance.scheduleSmartReminder(_tasks.where((t) => !t.isCompleted).length);
  }

  void _updateTask(TaskItem updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        final oldTask = _tasks[index];
        if (updatedTask.isCompleted && !oldTask.isCompleted) {
          _awardXP(25);
        }
        _tasks[index] = updatedTask;
        DatabaseService.instance.saveTask(updatedTask);

        // Sync scheduled time blocks with updated task state
        _timeblocks.forEach((hour, task) {
          if (task?.id == updatedTask.id) {
            _timeblocks[hour] = updatedTask;
          }
        });
      }
    });
    NotificationService.instance.scheduleSmartReminder(_tasks.where((t) => !t.isCompleted).length);
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
      _timeblocks.forEach((hour, task) {
        if (task?.id == id) {
          _timeblocks[hour] = null;
        }
      });
      DatabaseService.instance.deleteTask(id);
    });
    NotificationService.instance.scheduleSmartReminder(_tasks.where((t) => !t.isCompleted).length);
  }

  void _updateTimeblock(String hour, TaskItem? task) {
    setState(() {
      _timeblocks[hour] = task;
      DatabaseService.instance.saveTimeblocks({hour: task?.id});
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retivy',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryLight,
                ),
              ),
            )
          : _currentUser == null
              ? LoginScreen(onLoginSuccess: _loadDatabase)
              : !_isBiometricUnlocked
                  ? BiometricLockScreen(
                      onUnlockSuccess: () {
                        setState(() {
                          _isBiometricUnlocked = true;
                        });
                      },
                      onReload: _loadDatabase,
                    )
                  : MainNavigationScreen(
                      habits: _habits,
                      tasks: _tasks,
                      timeblocks: _timeblocks,
                      xp: _xp,
                      level: _level,
                      onAwardXP: _awardXP,
                      onUpdateHabit: _updateHabit,
                      onAddHabit: _addHabit,
                      onResetAll: _resetAllHabits,
                      onToggleTheme: _toggleTheme,
                      isDarkMode: _isDarkMode,
                      onAddTask: _addTask,
                      onUpdateTask: _updateTask,
                      onDeleteTask: _deleteTask,
                      onUpdateTimeblock: _updateTimeblock,
                      onReloadDatabase: _loadDatabase,
                      initialIndex: 0,
                    ),
    );
  }
}
