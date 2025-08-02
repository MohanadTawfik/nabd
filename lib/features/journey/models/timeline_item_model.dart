

import 'package:flutter/material.dart';

/// Enum representing different types of timeline items
enum TimelineItemType {
  expense,
  income,
  budget,
  goal,
  milestone,
  achievement,
  alert,
}

/// A model class representing an item on the financial journey timeline
class TimelineItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;
  final Color color;
  final TimelineItemType type;
  final dynamic data; // Optional additional data related to this item

  TimelineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
    required this.type,
    this.data,
  });

  // Factory method to create a TimelineItem from a map
  factory TimelineItem.fromMap(Map<String, dynamic> map) {
    return TimelineItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      type: TimelineItemType.values.byName(map['type']),
      data: map['data'],
    );
  }

  // Convert TimelineItem to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'type': type.name,
      'data': data,
    };
  }
}
