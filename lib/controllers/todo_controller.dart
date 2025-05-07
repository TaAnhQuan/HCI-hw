import 'dart:io';

import 'package:app/models/record_entity.dart';
import 'package:app/models/summary_entity.dart';
import 'package:app/services/embeddings_service.dart';
import 'package:app/services/objectbox_service.dart';

import '../models/todo_entity.dart';

class TodoController {
  final Status status;
  List<ShownTask> resultToBeShown = [];

  TodoController({required this.status});

  List<ShownTask>? getResultsByStatus() {
    late List<TodoEntity>? todoEntities;
    if (status == Status.all) {
      todoEntities = ObjectBoxService().getAllTodos();
    } else{
      todoEntities = ObjectBoxService().getTodosByStatus(status);
    }
    if (todoEntities == null) {
      return null;
    }
    for (var todo in todoEntities) {
      resultToBeShown.add(
          ShownTask(task: todo.task, details: todo.detail, deadline: todo.deadline)
      );
    }

    return resultToBeShown;
  }
}

class ShownTask {
  late String? task;
  late String? details;
  late int? deadline;

  ShownTask({required this.task, required this.details, required this.deadline});
}