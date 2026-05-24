import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum HabitType { numeric, timer, checklist }

class Habit {
  final String id;
  final String title;
  final String description;
  final HabitType type;
  final String iconName; // e.g. "water_drop", "menu_book", "medication"
  final String colorKey; // "primary", "secondary", "tertiary"
  final bool isCompleted;
  final bool isSkipped;
  final String? skipReason;
  
  // Numeric properties
  final double currentValue;
  final double targetValue;
  final String unit;
  final double stepValue;

  // Timer properties
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.iconName,
    required this.colorKey,
    this.isCompleted = false,
    this.isSkipped = false,
    this.skipReason,
    this.currentValue = 0.0,
    this.targetValue = 0.0,
    this.unit = '',
    this.stepValue = 0.0,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.isRunning = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitType? type,
    String? iconName,
    String? colorKey,
    bool? isCompleted,
    bool? isSkipped,
    String? skipReason,
    double? currentValue,
    double? targetValue,
    String? unit,
    double? stepValue,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorKey: colorKey ?? this.colorKey,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      skipReason: skipReason != null ? (skipReason == "" ? null : skipReason) : this.skipReason,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      stepValue: stepValue ?? this.stepValue,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'iconName': iconName,
      'colorKey': colorKey,
      'isCompleted': isCompleted ? 1 : 0,
      'isSkipped': isSkipped ? 1 : 0,
      'skipReason': skipReason,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'unit': unit,
      'stepValue': stepValue,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: HabitType.values.byName(map['type'] as String),
      iconName: map['iconName'] as String,
      colorKey: map['colorKey'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      isSkipped: (map['isSkipped'] as int) == 1,
      skipReason: map['skipReason'] as String?,
      currentValue: (map['currentValue'] as num).toDouble(),
      targetValue: (map['targetValue'] as num).toDouble(),
      unit: map['unit'] as String,
      stepValue: (map['stepValue'] as num).toDouble(),
      totalSeconds: map['totalSeconds'] as int,
      remainingSeconds: map['remainingSeconds'] as int,
      isRunning: (map['isRunning'] as int) == 1,
    );
  }


  IconData get iconData {
    switch (iconName) {
      case 'water_drop':
        return LucideIcons.droplets;
      case 'menu_book':
        return LucideIcons.bookOpen;
      case 'pill':
      case 'medication':
        return LucideIcons.pill;
      case 'directions_run':
        return LucideIcons.footprints;
      case 'fitness_center':
        return LucideIcons.dumbbell;
      case 'edit':
        return LucideIcons.edit;
      case 'bed':
        return LucideIcons.bed;
      default:
        return LucideIcons.star;
    }
  }
}
