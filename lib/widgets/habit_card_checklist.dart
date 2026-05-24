import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';

class HabitCardChecklist extends StatefulWidget {
  final Habit habit;
  final ValueChanged<Habit> onUpdate;
  final VoidCallback onSkipToggle;

  const HabitCardChecklist({
    super.key,
    required this.habit,
    required this.onUpdate,
    required this.onSkipToggle,
  });

  @override
  State<HabitCardChecklist> createState() => _HabitCardChecklistState();
}

class _HabitCardChecklistState extends State<HabitCardChecklist> {
  double _checkScale = 1.0;

  Color _getColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == 'secondary') return colors.secondary;
    if (key == 'tertiary') return colors.tertiary;
    return colors.primary;
  }

  void _showSkipDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Pilih Alasan Skip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Streak Anda tetap aman secara visual.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  'Sakit 🤒',
                  'Liburan ✈️',
                  'Urusan Darurat 🚨',
                  'Rest Day 😴',
                  'Lainnya ⚙️'
                ].map((reason) {
                  return ActionChip(
                    label: Text(reason),
                    onPressed: () {
                      Navigator.pop(context, reason);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    ).then((reason) {
      if (reason != null) {
        widget.onUpdate(widget.habit.copyWith(
          isSkipped: true,
          skipReason: reason,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSkipped = widget.habit.isSkipped;
    final isCompleted = widget.habit.isCompleted;
    final activeColor = _getColor(context, widget.habit.colorKey);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSkipped ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.light ? 0.03 : 0.12),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
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
              child: Row(
                children: [
                  // Checked indicator circle with micro-animation
                  if (!isSkipped) ...[
                    GestureDetector(
                      onTapDown: (_) => setState(() => _checkScale = 0.9),
                      onTapUp: (_) => setState(() => _checkScale = 1.0),
                      onTapCancel: () => setState(() => _checkScale = 1.0),
                      onTap: () {
                        widget.onUpdate(widget.habit.copyWith(
                          isCompleted: !isCompleted,
                        ));
                      },
                      child: AnimatedScale(
                        scale: _checkScale,
                        duration: const Duration(milliseconds: 100),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCompleted ? activeColor : theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? activeColor
                                  : theme.colorScheme.outlineVariant,
                              width: 3.0,
                            ),
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: isCompleted ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.elasticOut,
                              child: const Icon(
                               LucideIcons.check,
                                color: Colors.white,
                                size: 24,
                                weight: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ] else ...[
                    // If skipped, show a disabled-looking placeholder icon instead of checkbox
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.habit.iconData,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],

                  // Content text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            decoration: isSkipped
                                ? TextDecoration.lineThrough
                                : isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                        if (isSkipped && widget.habit.skipReason != null) ...[
                          const SizedBox(height: 2.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'Skipped: ${widget.habit.skipReason}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            widget.habit.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: () {
                      if (isSkipped) {
                        widget.onUpdate(widget.habit.copyWith(
                          isSkipped: false,
                          skipReason: "",
                        ));
                      } else {
                        _showSkipDialog(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      isSkipped ? 'Resume' : 'Skip',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
