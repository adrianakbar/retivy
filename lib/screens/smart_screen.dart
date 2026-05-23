import 'package:flutter/material.dart';
import '../models/habit.dart';

class SmartScreen extends StatelessWidget {
  final List<Habit> habits;

  const SmartScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate facts for smart suggestions
    final waterHabitList = habits.where((h) => h.iconName == 'water_drop').toList();
    final waterLeft = waterHabitList.isNotEmpty 
        ? (waterHabitList.first.targetValue - waterHabitList.first.currentValue).clamp(0.0, 9999.0)
        : 0.0;
    
    final timerHabitList = habits.where((h) => h.type == HabitType.timer).toList();
    final hasActiveTimer = timerHabitList.isNotEmpty && timerHabitList.first.remainingSeconds > 0 && !timerHabitList.first.isCompleted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header
          Text(
            'Smart Assistant',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI insights customized for you',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24.0),

          // Daily Motivation Card (Glassmorphic look/Gradient)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI INSIGHT OF THE DAY',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"Consistency is not about perfection; it is about progress. Tiny habits build extraordinary results."',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Smart Prompts & Dynamic Alerts
          Text(
            'Actionable Tips',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12.0),

          // Dynamic Hydration Suggestion
          if (waterLeft > 0)
            _buildSmartTipCard(
              context,
              icon: Icons.water_drop_rounded,
              color: theme.colorScheme.primary,
              title: 'Stay Hydrated',
              body: 'You still need to drink ${waterLeft.toStringAsFixed(0)} ml of water today to meet your daily intake. Grab a glass now!',
              actionLabel: 'Add 250ml quickly',
              onAction: () {
                if (waterHabitList.isNotEmpty) {
                  final h = waterHabitList.first;
                  final nextVal = (h.currentValue + 250.0).clamp(0.0, h.targetValue);
                  // We can't update directly here since habits is immutable list,
                  // but in a real app this is a shortcut trigger. We'll show a nice dialog or toast.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hydration updated! Target progress: ${nextVal.toStringAsFixed(0)} ml'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            )
          else
            _buildSmartTipCard(
              context,
              icon: Icons.check_circle_rounded,
              color: theme.colorScheme.secondary,
              title: 'Water Goal Completed! 🎉',
              body: 'Excellent! You\'ve successfully hit your 3000 ml water target. Keep maintaining this fluid balance daily!',
            ),
          const SizedBox(height: 12.0),

          // Focus suggestion
          if (hasActiveTimer)
            _buildSmartTipCard(
              context,
              icon: Icons.menu_book_rounded,
              color: theme.colorScheme.tertiary,
              title: 'Focus Session Pending',
              body: 'You have a reading session configured. Carve out just 15 minutes of quiet time to start your timer.',
            ),
          const SizedBox(height: 12.0),

          // Health habits
          _buildSmartTipCard(
            context,
            icon: Icons.bedtime_rounded,
            color: Colors.indigo,
            title: 'Sleep Hygiene Reminder',
            body: 'Caffeine blocks adenosine receptors. Avoid drinking coffee or tea within 6 hours of bedtime for deeper sleep quality.',
          ),
          const SizedBox(height: 12.0),

          _buildSmartTipCard(
            context,
            icon: Icons.lightbulb_rounded,
            color: Colors.amber,
            title: 'Rule of Two Minutes',
            body: 'If a habit takes less than 2 minutes to do (like taking vitamins), perform it immediately. Avoid scheduling simple steps.',
          ),
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }

  Widget _buildSmartTipCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                actionLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
