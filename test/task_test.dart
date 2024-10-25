import 'package:flutter_test/flutter_test.dart';

import 'package:sembast/sembast_memory.dart';
import 'package:todo_app_ga/features/task/models/task.dart';
import 'package:todo_app_ga/features/task/repositories/sembast_task_repository.dart';

void main() {
  group('Task Model Tests', () {
    final testTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Task Description',
      isCompleted: false,
    );
    test('Should create Task instance with correct values', () {
      expect(testTask.id, '1');
      expect(testTask.title, 'Test Task');
      expect(testTask.description, 'Task Description');
      expect(testTask.isCompleted, false);
    });

    test('Should convert Task to Map correctly', () {
      final map = testTask.toMap();
      expect(map['id'], '1');
      expect(map['title'], 'Test Task');
      expect(map['description'], 'Task Description');
      expect(map['isCompleted'], false);
    });

    test('Should create Task from Map correctly', () {
      final map = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Task Description',
        'isCompleted': false,
      };
      final task = Task.fromMap(map);
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Task Description');
      expect(task.isCompleted, false);
    });

    test('Should create copy with modified values', () {
      final modifiedTask = testTask.copyWith(
        null,
        'New Title',
        'New Description',
        true,
      );
      expect(modifiedTask.id, '1');
      expect(modifiedTask.title, 'New Title');
      expect(modifiedTask.description, 'New Description');
      expect(modifiedTask.isCompleted, true);
    });
    test('toString should return correct string represantation', () {
      const String testTaskString =
          'Task with id: 1\n title: Test Task\n description: Task Description\n isCompleted: false ';
      expect(testTask.toString(), testTaskString);
    });
  });
  group('SembastTaskRepository Tests', () {
    late Database database;
    late SembastTaskRepository repository;
    late StoreRef store;
    setUp(() async {
      database = await databaseFactoryMemory.openDatabase('test.db');
      repository = SembastTaskRepository(database);
      store = stringMapStoreFactory.store('Tasks');
    });
    tearDown(() async {
      await store.drop(database);
      await database.close();
    });

    test('Should return empty list when no tasks exist', () async {
      final tasks = await repository.getAllTask();
      expect(
        tasks,
        isEmpty,
      );
    });
    test('Should add and retrieve task', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Task Description',
      );
      await repository.addTask(task);
      final tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      expect(tasks.first.id, task.id);
      expect(tasks.first.title, task.title);
      expect(tasks.first.description, task.description);
      expect(tasks.first.isCompleted, task.isCompleted);
    });
    test('Should delete task', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Task Description',
      );
      await repository.addTask(task);
      var tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      await repository.deleteTask(task.id);
      tasks = await repository.getAllTask();
      expect(tasks, isEmpty);
    });
    test('Should update task', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Task Description',
      );
      await repository.addTask(task);
      var tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      final updatedTask = task.copyWith(
        null,
        'Updated task',
        'Updated description',
        true,
      );
      await repository.updateTask(updatedTask);
      tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      expect(tasks.first.id, updatedTask.id);
      expect(tasks.first.title, updatedTask.title);
      expect(tasks.first.description, updatedTask.description);
      expect(tasks.first.isCompleted, updatedTask.isCompleted);
    });
    test('Should handle multiple tasks', () async {
      final tasks = [
        Task(id: '1', title: 'Task 1'),
        Task(id: '2', title: 'Task 2'),
        Task(id: '3', title: 'Task 3'),
      ];
      for (var task in tasks) {
        await repository.addTask(task);
      }
      final retrievedTasks = await repository.getAllTask();
      expect(retrievedTasks.length, 3);
    });
    test('Should throw Exception when adding duplicate task', () async {
      Task task1 = Task(id: '11', title: 'Test Task');
      await repository.addTask(task1);
      expect(() async => await repository.addTask(task1),
          throwsA(isA<Exception>()));
    });
  });

  group('Integration Tests', () {
    late Database database;
    late SembastTaskRepository repository;
    late StoreRef store;
    setUp(() async {
      database =
          await databaseFactoryMemory.openDatabase('integration_test.db');
      repository = SembastTaskRepository(database);
      store = stringMapStoreFactory.store();
    });
    tearDown(() async {
      await store.drop(database);
      await database.close();
    });
    test('Should perform full CRUD cycle', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Testing full CRUD cycle',
      );
      await repository.addTask(task);
      var tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      expect(tasks.first.id, task.id);
      expect(tasks.first.title, task.title);
      expect(tasks.first.description, task.description);
      expect(tasks.first.isCompleted, task.isCompleted);
      final updatedTask = Task(
        id: '1',
        title: 'Updated Test Task',
        description: 'Updated Testing full CRUD cycle',
        isCompleted: true,
      );
      await repository.updateTask(updatedTask);
      tasks = await repository.getAllTask();
      expect(tasks.length, 1);
      expect(tasks.first.id, updatedTask.id);
      expect(tasks.first.title, updatedTask.title);
      expect(tasks.first.description, updatedTask.description);
      expect(tasks.first.isCompleted, updatedTask.isCompleted);
      await repository.deleteTask('1');
      tasks = await repository.getAllTask();
      expect(tasks, isEmpty);
    });
  });
}
