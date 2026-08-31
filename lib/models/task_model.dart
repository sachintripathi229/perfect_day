import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  bool isCompleted;
  String date; // ISO 8601 date string (YYYY-MM-DD)

  Task({
    required this.title,
    this.isCompleted = false,
    String? date,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now().toIso8601String().split('T').first;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'date': date,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
        date: json['date'] as String,
      );

  Task copyWith({String? title, bool? isCompleted, String? date}) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }
}
