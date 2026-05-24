import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/habit.dart';

class NewHabitDialog extends StatefulWidget {
  const NewHabitDialog({super.key});

  @override
  State<NewHabitDialog> createState() => _NewHabitDialogState();
}

class _NewHabitDialogState extends State<NewHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  HabitType _selectedType = HabitType.checklist;
  String _selectedIcon = 'water_drop';
  String _selectedColorKey = 'primary';

  // Numeric specific fields
  final _targetController = TextEditingController(text: '2000');
  final _stepController = TextEditingController(text: '250');
  final _unitController = TextEditingController(text: 'ml');

  // Timer specific fields
  final _durationController = TextEditingController(text: '25'); // minutes

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _stepController.dispose();
    _unitController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'water_drop':
        return LucideIcons.droplet;
      case 'menu_book':
        return LucideIcons.book;
      case 'pill':
        return LucideIcons.pill;
      case 'directions_run':
        return LucideIcons.footprints;
      case 'bed':
        return LucideIcons.bed;
      default:
        return LucideIcons.star;
    }
  }

  Color _getColor(String key) {
    if (key == 'secondary') return const Color(0xFF006C49);
    if (key == 'tertiary') return const Color(0xFF825100);
    return const Color(0xFF4648D4);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    double currentVal = 0.0;
    double targetVal = 0.0;
    double stepVal = 0.0;
    String unit = '';
    int totalSecs = 0;

    if (_selectedType == HabitType.numeric) {
      targetVal = double.tryParse(_targetController.text) ?? 2000.0;
      stepVal = double.tryParse(_stepController.text) ?? 250.0;
      unit = _unitController.text;
    } else if (_selectedType == HabitType.timer) {
      final mins = int.tryParse(_durationController.text) ?? 25;
      totalSecs = mins * 60;
    }

    final newHabit = Habit(
      id: id,
      title: _titleController.text,
      description: _descController.text,
      type: _selectedType,
      iconName: _selectedIcon,
      colorKey: _selectedColorKey,
      currentValue: currentVal,
      targetValue: targetVal,
      stepValue: stepVal,
      unit: unit,
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
      isCompleted: false,
      isSkipped: false,
    );

    Navigator.pop(context, newHabit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 12.0,
        bottom: mediaQuery.viewInsets.bottom + 24.0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24.0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottomsheet handle
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Habit',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Habit Title',
                  hintText: 'e.g. Drink Water, Read a Book',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),

              // Description Field
              TextFormField(
                controller: _descController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  hintText: 'e.g. Stay hydrated throughout the day',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Habit Type Segment Picker
              Text(
                'Habit Type',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8.0),
              SegmentedButton<HabitType>(
                segments: const [
                  ButtonSegment(
                    value: HabitType.checklist,
                    icon: Icon(LucideIcons.checkSquare),
                    label: Text('Checklist'),
                  ),
                  ButtonSegment(
                    value: HabitType.numeric,
                    icon: Icon(LucideIcons.droplet),
                    label: Text('Numeric'),
                  ),
                  ButtonSegment(
                    value: HabitType.timer,
                    icon: Icon(LucideIcons.timer),
                    label: Text('Timer'),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<HabitType> selection) {
                  setState(() {
                    _selectedType = selection.first;
                    // Auto-adjust default icon for type
                    if (_selectedType == HabitType.numeric) {
                      _selectedIcon = 'water_drop';
                      _selectedColorKey = 'primary';
                    } else if (_selectedType == HabitType.timer) {
                      _selectedIcon = 'menu_book';
                      _selectedColorKey = 'tertiary';
                    } else {
                      _selectedIcon = 'pill';
                      _selectedColorKey = 'secondary';
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Dynamic Parameters depending on Type
              if (_selectedType == HabitType.numeric) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _targetController,
                        style: theme.textTheme.bodyLarge,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Daily Goal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (val) =>
                            double.tryParse(val ?? '') == null ? 'Invalid goal' : null,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _stepController,
                        style: theme.textTheme.bodyLarge,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Add Step',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (val) =>
                            double.tryParse(val ?? '') == null ? 'Invalid step' : null,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Invalid unit' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ] else if (_selectedType == HabitType.timer) ...[
                TextFormField(
                  controller: _durationController,
                  style: theme.textTheme.bodyLarge,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Timer Duration (Minutes)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (val) =>
                      int.tryParse(val ?? '') == null ? 'Invalid duration' : null,
                ),
                const SizedBox(height: 16.0),
              ],

              // Visual Theme Pickers (Colors and Icons)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Theme',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: ['primary', 'secondary', 'tertiary'].map((key) {
                            final color = _getColor(key);
                            final isSelected = _selectedColorKey == key;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColorKey = key),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12.0),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: theme.colorScheme.onSurface,
                                          width: 3.0,
                                        )
                                      : null,
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 6.0,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Icon selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Icon Picker',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['water_drop', 'menu_book', 'pill', 'directions_run', 'bed'].map((name) {
                              final isSelected = _selectedIcon == name;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedIcon = name),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.surfaceContainerHigh
                                        : theme.colorScheme.surfaceContainerLow,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: theme.colorScheme.onSurface,
                                            width: 2.0,
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    _getIconData(name),
                                    size: 18,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(_selectedColorKey),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Text(
                  'Create Habit',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
