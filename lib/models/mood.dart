import 'package:flutter/material.dart';

class Mood {
  final DateTime date;
  final String emoji;
  final String label;
  final String? note;
  final Color color;

  Mood({
    required this.date,
    required this.emoji,
    required this.label,
    this.note,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'emoji': emoji,
      'label': label,
      'note': note,
      'color': color.value,
    };
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      date: DateTime.parse(json['date']),
      emoji: json['emoji'],
      label: json['label'],
      note: json['note'],
      color: Color(json['color']),
    );
  }
} 