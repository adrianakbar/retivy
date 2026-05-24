import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';
import '../widgets/habit_card_numeric.dart';
import '../widgets/habit_card_timer.dart';
import '../widgets/habit_card_checklist.dart';
import '../widgets/new_habit_dialog.dart';

class HabitsScreen extends StatelessWidget {
  final List<Habit> habits;
  final ValueChanged<Habit> onUpdateHabit;
  final ValueChanged<Habit> onAddHabit;
  final VoidCallback onResetAll;

  const HabitsScreen({
    super.key,
    required this.habits,
    required this.onUpdateHabit,
    required this.onAddHabit,
    required this.onResetAll,
  });

  void _showAddHabitSheet(BuildContext context) async {
    final newHabit = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewHabitDialog(),
    );

    if (newHabit != null) {
      onAddHabit(newHabit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Habits Title and Header Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Habits',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your momentum going.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Reset All Button
                IconButton(
                  tooltip: 'Reset all daily habits',
                  icon: Icon(
                    LucideIcons.refreshCw,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Daily Progress?'),
                        content: const Text(
                            'Are you sure you want to clear your current progress and skipped states for all daily habits?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onResetAll();
                            },
                            child: Text(
                              'Reset All',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Habits List
            if (habits.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.lineChart,
                        size: 64,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No habits added yet!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Tap the button below to add your first habit.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  Widget card;

                  switch (habit.type) {
                    case HabitType.numeric:
                      card = HabitCardNumeric(
                        habit: habit,
                        onUpdate: onUpdateHabit,
                        onSkipToggle: () {
                          onUpdateHabit(habit.copyWith(
                            isSkipped: !habit.isSkipped,
                            isRunning: false, // Turn off timer if skipped
                          ));
                        },
                      );
                      break;
                    case HabitType.timer:
                      card = HabitCardTimer(
                        habit: habit,
                        onUpdate: onUpdateHabit,
                        onSkipToggle: () {
                          onUpdateHabit(habit.copyWith(
                            isSkipped: !habit.isSkipped,
                            isRunning: false, // Pause active timers
                          ));
                        },
                      );
                      break;
                    case HabitType.checklist:
                      card = HabitCardChecklist(
                        habit: habit,
                        onUpdate: onUpdateHabit,
                        onSkipToggle: () {
                          onUpdateHabit(habit.copyWith(
                            isSkipped: !habit.isSkipped,
                          ));
                        },
                      );
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: card,
                  );
                },
              ),
            const SizedBox(height: 80.0), // Spacer bottom sheet padding
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddHabitSheet(context),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          icon: const Icon(LucideIcons.plus),
          label: const Text(
            'Add Habit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
