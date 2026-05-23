import 'package:flutter/material.dart';
import '../models/task_item.dart';

class TasksScreen extends StatefulWidget {
  final ValueChanged<int> onAwardXP;
  final List<TaskItem> tasks;
  final Map<String, TaskItem?> timeblocks;
  final ValueChanged<TaskItem> onAddTask;
  final ValueChanged<TaskItem> onUpdateTask;
  final ValueChanged<String> onDeleteTask;
  final Function(String, TaskItem?) onUpdateTimeblock;

  const TasksScreen({
    super.key,
    required this.onAwardXP,
    required this.tasks,
    required this.timeblocks,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onUpdateTimeblock,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Daily schedule time blocks
  final List<String> _timeblockHours = [
    '07:00 AM',
    '09:00 AM',
    '12:00 PM',
    '03:00 PM',
    '06:00 PM',
    '08:00 PM',
  ];

  final _textController = TextEditingController();
  int _activeSegment = 0; // 0 for Task List, 1 for Time Blocking

  // Smart text parser variables
  String? _parsedDate;
  String? _parsedTime;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }


  void _onTextChanged() {
    final text = _textController.text.trim().toLowerCase();
    String? dateStr;
    String? timeStr;

    if (text.isEmpty) {
      setState(() {
        _parsedDate = null;
        _parsedTime = null;
      });
      return;
    }

    // Parse Dates
    if (text.contains('besok')) {
      dateStr = '📅 Besok';
    } else if (text.contains('hari ini')) {
      dateStr = '📅 Hari Ini';
    }

    // Parse Times
    if (text.contains('nanti malam') || text.contains('malam')) {
      timeStr = '⏰ 8:00 PM';
    } else if (text.contains('pagi')) {
      timeStr = '⏰ 8:00 AM';
    } else if (text.contains('siang')) {
      timeStr = '⏰ 12:00 PM';
    } else if (text.contains('jam 7') || text.contains('jam tujuh') || text.contains('pukul 7')) {
      timeStr = '⏰ 7:00 PM';
    }

    setState(() {
      _parsedDate = dateStr;
      _parsedTime = timeStr;
    });
  }

  void _addTask() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    String finalTitle = text;
    if (_parsedDate != null || _parsedTime != null) {
      final datePart = _parsedDate ?? '';
      final timePart = _parsedTime ?? '';
      final space = (datePart.isNotEmpty && timePart.isNotEmpty) ? ' ' : '';
      finalTitle = '$text ($datePart$space$timePart)';
    }

    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: finalTitle,
    );
    widget.onAddTask(newTask);

    setState(() {
      _textController.clear();
      _parsedDate = null;
      _parsedTime = null;
    });
  }

  void _toggleTask(int index) {
    final item = widget.tasks[index];
    widget.onUpdateTask(item.copyWith(isCompleted: !item.isCompleted));
  }

  void _deleteTask(int index) {
    final item = widget.tasks[index];
    widget.onDeleteTask(item.id);
  }

  void _showTimeblockSelector(String hour) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Schedule Task to $hour',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a daily task to allocate this time block (Time-Blocking method).',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16.0),
              widget.tasks.isEmpty
                  ? const Center(child: Text('No tasks available. Add one in the Task List tab!'))
                  : Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.tasks.length,
                        itemBuilder: (context, idx) {
                          final task = widget.tasks[idx];
                          return ListTile(
                            leading: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            onTap: () {
                              widget.onUpdateTimeblock(hour, task);
                              Navigator.pop(context);
                              widget.onAwardXP(15);
                            },
                          );
                        },
                      ),
                    ),
              if (widget.timeblocks[hour] != null) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                  title: const Text('Remove scheduled task', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    widget.onUpdateTimeblock(hour, null);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = widget.tasks.where((t) => t.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Tasks',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _activeSegment == 0
                        ? 'Auxiliary daily action lists'
                        : 'Visual 24h daily schedule blocks',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _activeSegment == 0 ? '$completedCount / ${widget.tasks.length}' : 'Time Block Active',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Sliding Tab Segment Toggle
          Center(
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.list_alt_rounded),
                    label: Text('Task List'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.calendar_today_rounded),
                    label: Text('Time Blocking'),
                  ),
                ],
                selected: {_activeSegment},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _activeSegment = newSelection.first;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Conditional rendering of Body Tabs
          Expanded(
            child: IndexedStack(
              index: _activeSegment,
              children: [
                // Tab 0: Task List (Classic + Smart Input Parsing)
                Column(
                  children: [
                    // Input Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'e.g. Beli susu besok jam 7 malam...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 14.0,
                              ),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _addTask,
                          child: Container(
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Smart Parser Chips Bar
                    if (_parsedDate != null || _parsedTime != null) ...[
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4.0),
                          Text(
                            'Parsed Tags: ',
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                          ),
                          if (_parsedDate != null) ...[
                            Chip(
                              label: Text(_parsedDate!, style: const TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4.0),
                          ],
                          if (_parsedTime != null)
                            Chip(
                              label: Text(_parsedTime!, style: const TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: theme.colorScheme.tertiary,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16.0),

                    // Tasks Scroll List
                    Expanded(
                      child: widget.tasks.isEmpty
                          ? const Center(child: Text('No auxiliary tasks listed!'))
                          : ListView.builder(
                              itemCount: widget.tasks.length,
                              itemBuilder: (context, index) {
                                final item = widget.tasks[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    leading: Checkbox(
                                      value: item.isCompleted,
                                      activeColor: theme.colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (_) => _toggleTask(index),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isCompleted
                                            ? theme.colorScheme.onSurfaceVariant
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      color: theme.colorScheme.error.withValues(alpha: 0.8),
                                      onPressed: () => _deleteTask(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // Tab 1: Time Blocking schedule timeline slots
                ListView.builder(
                  itemCount: _timeblockHours.length,
                  itemBuilder: (context, index) {
                    final hour = _timeblockHours[index];
                    final scheduledTask = widget.timeblocks[hour];
                    final hasTask = scheduledTask != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: hasTask
                              ? theme.colorScheme.primary.withValues(alpha: 0.4)
                              : theme.colorScheme.outlineVariant,
                          width: hasTask ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Time Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hour,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Timeblock',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16.0),

                          // Vertical divider line
                          Container(
                            width: 3.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: hasTask
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          const SizedBox(width: 16.0),

                          // Scheduled Task Card or Placeholder empty slot
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showTimeblockSelector(hour),
                              child: hasTask
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                scheduledTask.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  decoration: scheduledTask.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: scheduledTask.isCompleted
                                                      ? theme.colorScheme.onSurfaceVariant
                                                      : theme.colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2.0),
                                              Text(
                                                scheduledTask.isCompleted ? 'Allocated • Done ✅' : 'Allocated • Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: scheduledTask.isCompleted
                                                      ? theme.colorScheme.secondary
                                                      : theme.colorScheme.onSurfaceVariant,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.edit_calendar_rounded, color: theme.colorScheme.primary, size: 20),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Empty Block (Tap to schedule task)',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.outline, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 70.0), // Padding below content for bottomnavbar spacer
        ],
      ),
    );
  }
}
