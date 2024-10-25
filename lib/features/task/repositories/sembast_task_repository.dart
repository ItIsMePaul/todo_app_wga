import 'package:sembast/sembast.dart';

import 'task_repository.dart';
import 'package:todo_app_ga/features/task/models/task.dart';

class SembastTaskRepository implements TaskRepository {
  final Database _database;
  final StoreRef _store;

  SembastTaskRepository(this._database)
      : _store = stringMapStoreFactory.store('Tasks');

  @override
  Future<List<Task>> getAllTask() async {
    try {
      final recordSnapshot = await _store.find(_database);
      return recordSnapshot.map((snapshot) {
        return Task.fromMap(snapshot.value as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Error when getting values from the database! Error: $e');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      final existing = await _store.record(task.id).get(_database);
      if (existing != null) {
        throw Exception('Task with id ${task.id} already exists!');
      }
      await _store.record(task.id).put(_database, task.toMap(), merge: false);
    } catch (e) {
      throw Exception('Error when adding value to the database! Error: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _store.record(id).delete(_database);
    } catch (e) {
      throw Exception('Error when deleting value from the database! Error: $e');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _store.record(task.id).update(
            _database,
            task.toMap(),
          );
    } catch (e) {
      throw Exception('Error when updating value in database! Error: $e');
    }
  }
}
