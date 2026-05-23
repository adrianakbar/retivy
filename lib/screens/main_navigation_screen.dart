import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';
import '../models/habit.dart';
import '../models/task_item.dart';
import 'habits_screen.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'smart_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<TaskItem> tasks;
  final Map<String, TaskItem?> timeblocks;
  final int xp;
  final int level;
  final ValueChanged<int> onAwardXP;
  final ValueChanged<Habit> onUpdateHabit;
  final ValueChanged<Habit> onAddHabit;
  final VoidCallback onResetAll;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final ValueChanged<TaskItem> onAddTask;
  final ValueChanged<TaskItem> onUpdateTask;
  final ValueChanged<String> onDeleteTask;
  final Function(String, TaskItem?) onUpdateTimeblock;
  final VoidCallback onReloadDatabase;

  const MainNavigationScreen({
    super.key,
    required this.habits,
    required this.tasks,
    required this.timeblocks,
    required this.xp,
    required this.level,
    required this.onAwardXP,
    required this.onUpdateHabit,
    required this.onAddHabit,
    required this.onResetAll,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onUpdateTimeblock,
    required this.onReloadDatabase,
  });


  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to Habits tab (Active in mock)
  bool _biometricActive = false;

  void _showProfileSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adrian Akbar',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Level ${widget.level} Habit Champion 🛡️',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'SECURITY & OFFLINE CONFIG',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Biometric Switch Row
                  SwitchListTile(
                    title: const Text('Kunci Biometrik (Fingerprint)'),
                    subtitle: Text(
                      _biometricActive ? 'Active 🔒 (offline-first)' : 'Inactive 🔓',
                      style: TextStyle(
                        color: _biometricActive ? theme.colorScheme.primary : theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _biometricActive,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      setModalState(() {
                        setState(() {
                          _biometricActive = value;
                        });
                      });
                      if (value) {
                        widget.onAwardXP(15);
                      }
                    },
                  ),
                  const Divider(),
                  // Local Backup Row
                  ListTile(
                    title: const Text('Export Backup Lokal (.json)'),
                    subtitle: const Text('Cadangkan data offline enkripsi lokal'),
                    trailing: Icon(Icons.download_rounded, color: theme.colorScheme.primary),
                    onTap: () async {
                      Navigator.pop(context);
                      final backupPath = await DatabaseService.instance.exportBackupAsJson();
                      widget.onAwardXP(25);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Backup berhasil! Disimpan di: $backupPath 💾 (+25 XP)'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(),
                  // Local Restore Row
                  ListTile(
                    title: const Text('Import Backup Lokal (.json)'),
                    subtitle: const Text('Pulihkan data offline enkripsi lokal'),
                    trailing: Icon(Icons.upload_rounded, color: theme.colorScheme.secondary),
                    onTap: () async {
                      Navigator.pop(context);
                      final documentsDirectory = await getApplicationDocumentsDirectory();
                      final backupPath = join(documentsDirectory.path, 'retivy_backup.json');
                      final file = File(backupPath);
                      if (!await file.exists()) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal: Berkas retivy_backup.json tidak ditemukan! Silakan lakukan export terlebih dahulu. ⚠️'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }

                      final success = await DatabaseService.instance.importBackupFromJsonFile(backupPath);
                      if (success) {
                        widget.onReloadDatabase();
                        widget.onAwardXP(30);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berhasil memulihkan cadangan Retivy! 🚀 (+30 XP)'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal membaca berkas cadangan! Format berkas rusak atau tidak valid. ⚠️'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAchievementsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        
        // Calculate milestones
        final waterDone = widget.habits.any((h) => h.iconName == 'water_drop' && h.isCompleted);
        final vitaminDone = widget.habits.any((h) => h.iconName == 'pill' && h.isCompleted);
        final timerElapsed = widget.habits.where((h) => h.type == HabitType.timer).map((h) => h.totalSeconds - h.remainingSeconds).firstOrNull ?? 0;
        final timerDone = timerElapsed >= 900; // 15 mins elapsed
        final levelDone = widget.level >= 3;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Icon(Icons.military_tech_rounded, size: 32, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 8.0),
                      Text(
                        'Milestone Badges',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Unlock milestones by completing offline daily habits!',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20.0),
                  _buildBadgeRow(
                    context,
                    title: 'Water Master I 💧',
                    desc: 'Minum 3000ml air dalam satu hari harian.',
                    progress: waterDone ? 1.0 : 0.5,
                    isUnlocked: waterDone,
                    themeColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12.0),
                  _buildBadgeRow(
                    context,
                    title: 'Focus Explorer 📚',
                    desc: 'Fokus membaca buku selama 15 menit.',
                    progress: timerDone ? 1.0 : (timerElapsed / 900).clamp(0.0, 1.0),
                    isUnlocked: timerDone,
                    themeColor: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(height: 12.0),
                  _buildBadgeRow(
                    context,
                    title: 'Supplement King 💊',
                    desc: 'Minum vitamin/suplemen harian Anda.',
                    progress: vitaminDone ? 1.0 : 0.0,
                    isUnlocked: vitaminDone,
                    themeColor: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 12.0),
                  _buildBadgeRow(
                    context,
                    title: 'Streak Builder 🔥',
                    desc: 'Pertahankan 5 hari berturut-turut streak habits.',
                    progress: 1.0,
                    isUnlocked: true,
                    themeColor: Colors.orange,
                  ),
                  const SizedBox(height: 12.0),
                  _buildBadgeRow(
                    context,
                    title: 'XP Overlord 👑',
                    desc: 'Capai level 3 dalam RPG system.',
                    progress: levelDone ? 1.0 : (widget.level / 3.0),
                    isUnlocked: levelDone,
                    themeColor: Colors.deepPurple,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBadgeRow(
    BuildContext context, {
    required String title,
    required String desc,
    required double progress,
    required bool isUnlocked,
    required Color themeColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isUnlocked ? themeColor.withValues(alpha: 0.4) : theme.colorScheme.outlineVariant,
          width: isUnlocked ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? themeColor.withValues(alpha: 0.12) : theme.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.verified_rounded : Icons.lock_rounded,
              color: isUnlocked ? themeColor : theme.colorScheme.outline,
              size: 24,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8.0),
                // Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: LinearProgressIndicator(
                          value: progress,
                          color: themeColor,
                          backgroundColor: theme.colorScheme.surfaceContainerHigh,
                          minHeight: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 10.0,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // List of screens based on active habits state
    final List<Widget> screens = [
      DashboardScreen(habits: widget.habits),
      HabitsScreen(
        habits: widget.habits,
        onUpdateHabit: widget.onUpdateHabit,
        onAddHabit: widget.onAddHabit,
        onResetAll: widget.onResetAll,
      ),
      TasksScreen(
        onAwardXP: widget.onAwardXP,
        tasks: widget.tasks,
        timeblocks: widget.timeblocks,
        onAddTask: widget.onAddTask,
        onUpdateTask: widget.onUpdateTask,
        onDeleteTask: widget.onDeleteTask,
        onUpdateTimeblock: widget.onUpdateTimeblock,
      ),
      SmartScreen(habits: widget.habits),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo + Avatar Section
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/retivy_logo.png',
                            width: 28,
                            height: 28,
                            color: theme.colorScheme.primary,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Retivy',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Trailing Icons (Trophy/Theme Toggle/Avatar Settings)
                      Row(
                        children: [
                          // Theme Switcher Button
                          IconButton(
                            tooltip: 'Toggle Theme',
                            icon: Icon(
                              widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            onPressed: widget.onToggleTheme,
                          ),
                          // Trophy/Achievements Button
                          IconButton(
                            tooltip: 'Milestone Tech Achievements',
                            icon: Icon(
                              Icons.military_tech_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            onPressed: () => _showAchievementsModal(context),
                          ),
                          const SizedBox(width: 6.0),
                          // Tappable Profile Avatar
                          GestureDetector(
                            onTap: () => _showProfileSettingsSheet(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surfaceContainerHigh,
                                border: Border.all(
                                  color: theme.colorScheme.primaryContainer,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // RPG Level & XP Bar Row
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 6.0),
                  child: Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'LV ${widget.level}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // XP Progress Bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Stack(
                            children: [
                              Container(
                                height: 8.0,
                                color: theme.colorScheme.surfaceContainerHigh,
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final xpTarget = widget.level * 200;
                                  final progress = (widget.xp / xpTarget).clamp(0.0, 1.0);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    height: 8.0,
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // XP Score string
                      Text(
                        '${widget.xp}/${widget.level * 200} XP',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          // Custom Bottom Navigation Bar matching Tailwind mock exactly
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        colors: theme.brightness == Brightness.light
                            ? [
                                Colors.white.withValues(alpha: 0.75),
                                Colors.white.withValues(alpha: 0.35),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.02),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, Icons.home_rounded, 'Home'),
                          _buildNavItem(1, Icons.cached_rounded, 'Habits'),
                          _buildNavItem(2, Icons.event_note_rounded, 'Tasks'),
                          _buildNavItem(3, Icons.location_on_rounded, 'Smart'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
