import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../models/task.dart';

// 전역 Provider 선언
final taskProvider = ChangeNotifierProvider<TaskNotifier>((ref) {
  return TaskNotifier()..load();
});

class TaskNotifier extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> tasksForDay(DateTime day) {
    final dateStr = day.toIso8601String().substring(0, 10);
    return _tasks
        .where((t) => t.date.toIso8601String().substring(0, 10) == dateStr)
        .toList();
  }

  bool hasTasksOnDay(DateTime day) => tasksForDay(day).isNotEmpty;

  Future<void> load() async {
    _tasks = await _db.getTasks();
    notifyListeners();
  }

  Future<void> add(Task task) async {
    final id = await _db.insertTask(task);
    _tasks.add(task.copyWith(id: id));
    notifyListeners();
  }

  Future<void> update(Task task) async {
    await _db.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> toggleComplete(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final updated = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    await _db.updateTask(updated);
    _tasks[index] = updated;
    notifyListeners();
  }
}
