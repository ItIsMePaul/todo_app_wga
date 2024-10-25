import 'package:todo_app_ga/features/task/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTask();

  Future<void> addTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String id);
}
