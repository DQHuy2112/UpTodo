import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

class Task {
  String title;
  String description;
  bool isCompleted;
  String category; // vẫn giữ field, nhưng UI không cho chọn/hiển thị
  TaskPriority priority;
  DateTime date;
  String time;

  Task({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.category,
    required this.priority,
    required this.date,
    required this.time,
  });
}
