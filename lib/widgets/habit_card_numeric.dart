import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';

class HabitCardNumeric extends StatefulWidget {
  final Habit habit;
  final ValueChanged<Habit> onUpdate;
  final VoidCallback onSkipToggle;

  const HabitCardNumeric({
    super.key,
    required this.habit,
    required this.onUpdate,
    required this.onSkipToggle,
  });

  @override
  State<HabitCardNumeric> createState() => _HabitCardNumericState();
}

class _HabitCardNumericState extends State<HabitCardNumeric> {
  double _buttonScale = 1.0;

  Color _getColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == 'secondary') return colors.secondary;
    if (key == 'tertiary') return colors.tertiary;
    return colors.primary;
  }

  Color _getContainerColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == 'secondary') return colors.secondaryContainer;
    if (key == 'tertiary') return colors.tertiaryContainer;
    return colors.primaryContainer;
  }

  Color _getOnContainerColor(BuildContext context, String key) {
    final colors = Theme.of(context).colorScheme;
    if (key == 'secondary') return colors.onSecondaryContainer;
    if (key == 'tertiary') return colors.onSecondaryContainer; // fallback to high contrast
    return colors.onPrimaryContainer;
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
    final valueColor = _getColor(context, widget.habit.colorKey);
    final containerColor = _getContainerColor(context, widget.habit.colorKey);
    final onContainerColor = _getOnContainerColor(context, widget.habit.colorKey);

    double progress = 0.0;
    if (widget.habit.targetValue > 0) {
      progress = (widget.habit.currentValue / widget.habit.targetValue).clamp(0.0, 1.0);
    }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section (Icon, Title, Description, Skip Button)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reverted to clean standard Material Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: containerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.habit.iconData,
                          color: onContainerColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      // Title and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.habit.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                decoration: isSkipped ? TextDecoration.lineThrough : null,
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
                  const SizedBox(height: 16.0),

                  // Progress text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.habit.currentValue.toStringAsFixed(0),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: valueColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' / ${widget.habit.targetValue.toStringAsFixed(0)} ${widget.habit.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Custom Animated Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(9999.0),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            height: 8.0,
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              color: valueColor,
                              borderRadius: BorderRadius.circular(9999.0),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Bottom Add Action Button
                  if (!isSkipped)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _buttonScale = 0.95),
                        onTapUp: (_) => setState(() => _buttonScale = 1.0),
                        onTapCancel: () => setState(() => _buttonScale = 1.0),
                        onTap: () {
                          final newValue = widget.habit.currentValue + widget.habit.stepValue;
                          final isDone = newValue >= widget.habit.targetValue;
                          widget.onUpdate(widget.habit.copyWith(
                            currentValue: newValue.clamp(0.0, widget.habit.targetValue),
                            isCompleted: isDone,
                          ));
                        },
                        child: AnimatedScale(
                          scale: _buttonScale,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: valueColor,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: valueColor.withValues(alpha: 0.15),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.plus,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${widget.habit.stepValue.toStringAsFixed(0)} ${widget.habit.unit}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
