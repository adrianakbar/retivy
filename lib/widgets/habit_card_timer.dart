import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/habit.dart';

class HabitCardTimer extends StatefulWidget {
  final Habit habit;
  final ValueChanged<Habit> onUpdate;
  final VoidCallback onSkipToggle;

  const HabitCardTimer({
    super.key,
    required this.habit,
    required this.onUpdate,
    required this.onSkipToggle,
  });

  @override
  State<HabitCardTimer> createState() => _HabitCardTimerState();
}

class _HabitCardTimerState extends State<HabitCardTimer> {
  Timer? _timer;
  double _resetScale = 1.0;
  double _actionScale = 1.0;

  @override
  void initState() {
    super.initState();
    // If it was somehow saved as running, let's start the timer
    if (widget.habit.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant HabitCardTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external state changes
    if (widget.habit.isRunning != oldWidget.habit.isRunning) {
      if (widget.habit.isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.habit.remainingSeconds > 0) {
        final nextSecs = widget.habit.remainingSeconds - 1;
        final completed = nextSecs == 0;
        widget.onUpdate(widget.habit.copyWith(
          remainingSeconds: nextSecs,
          isCompleted: completed ? true : widget.habit.isCompleted,
          isRunning: !completed,
        ));
        if (completed) {
          _timer?.cancel();
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _toggleTimer() {
    final nextRunning = !widget.habit.isRunning;
    widget.onUpdate(widget.habit.copyWith(isRunning: nextRunning));
    if (nextRunning) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _resetTimer() {
    _stopTimer();
    widget.onUpdate(widget.habit.copyWith(
      remainingSeconds: widget.habit.totalSeconds,
      isRunning: false,
      isCompleted: false,
    ));
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
          isRunning: false,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSkipped = widget.habit.isSkipped;
    final activeColor = _getColor(context, widget.habit.colorKey);
    final containerColor = _getContainerColor(context, widget.habit.colorKey);
    final onContainerColor = _getOnContainerColor(context, widget.habit.colorKey);

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
                  const SizedBox(height: 20.0),

                  // Timer Display Area
                  Center(
                    child: Text(
                      _formatDuration(widget.habit.remainingSeconds),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        color: widget.habit.isCompleted
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Reset and Start/Pause Row Buttons
                  if (!isSkipped)
                    Row(
                      children: [
                        // Reset Button (1/3 width)
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _resetScale = 0.95),
                            onTapUp: (_) => setState(() => _resetScale = 1.0),
                            onTapCancel: () => setState(() => _resetScale = 1.0),
                            onTap: _resetTimer,
                            child: AnimatedScale(
                              scale: _resetScale,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restart_alt,
                                      size: 18,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Reset',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Start/Pause Button (2/3 width)
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _actionScale = 0.95),
                            onTapUp: (_) => setState(() => _actionScale = 1.0),
                            onTapCancel: () => setState(() => _actionScale = 1.0),
                            onTap: _toggleTimer,
                            child: AnimatedScale(
                              scale: _actionScale,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: activeColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: activeColor.withValues(alpha: 0.15),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.habit.isRunning ? Icons.pause : Icons.play_arrow,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      widget.habit.isRunning ? 'Pause Session' : 'Start Timer',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
