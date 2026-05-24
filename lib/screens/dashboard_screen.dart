import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../models/habit.dart';

class DashboardScreen extends StatelessWidget {
  final List<Habit> habits;

  const DashboardScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Stats calculation
    final totalHabits = habits.length;
    final completedHabits = habits.where((h) => h.isCompleted).length;
    final skippedHabits = habits.where((h) => h.isSkipped).length;
    final activeHabits = totalHabits - skippedHabits;
    
    double completionRate = 0.0;
    if (activeHabits > 0) {
      completionRate = completedHabits / activeHabits;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Streak row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${AuthService.instance.currentUserValue?.name ?? 'Adrian'}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is your summary for today',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Flame streak widget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.flame,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5 Days',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Core Metric Progress Ring Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Visual Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: completionRate,
                        strokeWidth: 8.0,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20.0),
                // Text metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Momentum Score',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You\'ve finished $completedHabits of $activeHabits active habits today!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      if (skippedHabits > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '($skippedHabits skipped)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Weekly Calendar View
          Text(
            'Weekly Performance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayItem(context, 'M', '17', false, true),
                _buildDayItem(context, 'T', '18', true, false),
                _buildDayItem(context, 'W', '19', true, false),
                _buildDayItem(context, 'T', '20', false, false),
                _buildDayItem(context, 'F', '21', true, false),
                _buildDayItem(context, 'S', '22', true, false),
                _buildDayItem(context, 'S', '23', false, false, isToday: true, rate: completionRate),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Insights & Activity Section
          Text(
            'Activity Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12.0),
          _buildAnalyticRow(
            context,
            icon: LucideIcons.droplets,
            color: theme.colorScheme.primary,
            title: 'Water Intake',
            value: 'Total consumed: ${_getWaterTotal()} ml',
            subtitle: 'Goal target: 3000 ml',
          ),
          const SizedBox(height: 12.0),
          _buildAnalyticRow(
            context,
            icon: LucideIcons.hourglass,
            color: theme.colorScheme.tertiary,
            title: 'Focus Duration',
            value: 'Timer session: ${_getTimerTotal()}',
            subtitle: 'Target session: 30 min',
          ),
          const SizedBox(height: 12.0),
          _buildAnalyticRow(
            context,
            icon: LucideIcons.shieldCheck,
            color: theme.colorScheme.secondary,
            title: 'Supplement Routine',
            value: _getVitaminStatus(),
            subtitle: 'Supplements / Vitamins tracker',
          ),
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }

  Widget _buildDayItem(
    BuildContext context,
    String dayLabel,
    String dateLabel,
    bool isCompleted,
    bool isSkipped, {
    bool isToday = false,
    double rate = 0.0,
  }) {
    final theme = Theme.of(context);
    final todayBorder = isToday ? theme.colorScheme.primary : Colors.transparent;

    Widget circleChild = Text(
      dateLabel,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: isToday
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );

    if (isCompleted) {
      circleChild = const Icon(LucideIcons.check, size: 14, color: Colors.white);
    } else if (isSkipped) {
      circleChild = Icon(LucideIcons.redo, size: 14, color: theme.colorScheme.outline);
    } else if (isToday && rate > 0) {
      circleChild = Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 2,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
            ),
          ),
          Text(
            dateLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          dayLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted
                ? theme.colorScheme.primary
                : isSkipped
                    ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerLow,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: todayBorder, width: 2)
                : Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Center(child: circleChild),
        ),
      ],
    );
  }

  Widget _buildAnalyticRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWaterTotal() {
    final waterHabit = habits.where((h) => h.iconName == 'water_drop');
    if (waterHabit.isEmpty) return '0';
    return waterHabit.first.currentValue.toStringAsFixed(0);
  }

  String _getTimerTotal() {
    final timerHabit = habits.where((h) => h.type == HabitType.timer);
    if (timerHabit.isEmpty) return '0:00';
    final elapsedSecs = timerHabit.first.totalSeconds - timerHabit.first.remainingSeconds;
    final mins = elapsedSecs ~/ 60;
    final secs = elapsedSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getVitaminStatus() {
    final vitaminHabit = habits.where((h) => h.iconName == 'pill');
    if (vitaminHabit.isEmpty) return 'No tracker active';
    final done = vitaminHabit.first.isCompleted;
    final skipped = vitaminHabit.first.isSkipped;
    if (skipped) return 'Skipped today';
    return done ? 'Routine Complete! ✅' : 'Pending completion';
  }
}
