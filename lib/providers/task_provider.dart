import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/storage_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get todayTasks => _tasks.where((t) {
        final today = DateTime.now().toIso8601String().split('T').first;
        return t.date == today;
      }).toList();

  List<Task> get weeklyTasks {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _tasks.where((t) {
      final taskDate = DateTime.parse(t.date);
      return !taskDate.isBefore(startOfWeek) && !taskDate.isAfter(endOfWeek);
    }).toList();
  }

  List<Task> get monthlyTasks {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return _tasks.where((t) {
      final taskDate = DateTime.parse(t.date);
      return !taskDate.isBefore(startOfMonth) && !taskDate.isAfter(endOfMonth);
    }).toList();
  }

  List<Task> get completedToday => todayTasks.where((t) => t.isCompleted).toList();
  List<Task> get completedWeekly => weeklyTasks.where((t) => t.isCompleted).toList();
  List<Task> get completedMonthly => monthlyTasks.where((t) => t.isCompleted).toList();

  double get todayProgress => todayTasks.isEmpty ? 0 : completedToday.length / todayTasks.length;
  double get weeklyProgress => weeklyTasks.isEmpty ? 0 : completedWeekly.length / weeklyTasks.length;
  double get monthlyProgress => monthlyTasks.isEmpty ? 0 : completedMonthly.length / monthlyTasks.length;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
    _save();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
      _save();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _save();
  }

  void updateTaskTitle(String id, String newTitle) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(title: newTitle);
      notifyListeners();
      _save();
    }
  }

  Future<void> loadTasks() async {
    _tasks = await StorageHelper.loadTasks();
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageHelper.saveTasks(_tasks);
  }
}
