import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/prompt_constants.dart';
import '../models/record_entity.dart';
import '../models/todo_entity.dart';
import 'embeddings_service.dart';
import 'llm.dart';
import 'objectbox_service.dart';

class TodoManager {
  static Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRunHourStr = prefs.getString('lastRunHour') ?? "";
    final currentTime = DateTime.now();
    final currentHourStr = DateFormat("yyyy-MM-dd HH").format(currentTime);

    if (currentHourStr == lastRunHourStr || (currentTime.hour != 11 && currentTime.hour != 23)) {
      return;
    }

    try {
      int? startTodoTime = lastRunHourStr != "" ? DateFormat("yyyy-MM-dd HH").parse(lastRunHourStr).millisecondsSinceEpoch : 0;

      Embeddings embeddings = await Embeddings.create();
      List<Map<String, dynamic>>? todos = await _genTodos(startTodoTime);
      if (todos != null) {
        List<TodoEntity> todoEntities = [];

        // Process each item in the summary array
        for (var item in todos) {
          String task = item['task'];
          String details = item['details'];
          int deadline = DateFormat("yyyy-MM-dd HH:mm").parse(item['deadline']).millisecondsSinceEpoch;
          List<double>? vector = await embeddings.getEmbeddings(task);

          todoEntities.add(TodoEntity(task: task, detail: details, deadline: deadline, vector: vector));
        }

        // Insert the summary entities into the ObjectBox database
        ObjectBoxService().createTodos(todoEntities);
        await prefs.setString('lastRunHour', currentHourStr);
      }
    } catch (e) {
      print("An error occurred while processing the to-do list: $e");
      throw Exception("An error occurred while processing the to-do list");
    }
  }

  static Future<List<Map<String, dynamic>>?> _genTodos(int startTime) async {
    List<RecordEntity> listRecords = ObjectBoxService().getRecordsByTimeRange(startTime, DateTime.now().millisecondsSinceEpoch);

    StringBuffer chatHistoryBuffer = StringBuffer();
    int chatLength = 0;
    List<String> chatHistories = [];
    for (RecordEntity record in listRecords) {
      String formattedTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(record.createdAt!));
      chatHistoryBuffer.write("($formattedTime) ${record.role}: ${record.content}\n");
      chatLength += "($formattedTime) ${record.role}: ${record.content}\n".length;
      if (chatLength > 128000) {
        chatHistories.add(chatHistoryBuffer.toString());
        chatLength = 0;
        chatHistoryBuffer.clear();
      }
    }

    if (chatHistoryBuffer.isNotEmpty) {
      chatHistories.add(chatHistoryBuffer.toString());
    }
    List<Map<String, dynamic>> allOutput = [];

    try {
      LLM todoLlm = await LLM.create('gpt-4o-mini', systemPrompt: systemPromptOfTask);

      for (String chatHistory in chatHistories) {
        String todos = await todoLlm.createRequest(content: chatHistory);
        RegExp regex = RegExp(r'```json\n(.*?)\n```', dotAll: true);
        Match? match = regex.firstMatch(todos);
        if (match != null) {
          String jsonContent = match.group(1) ?? "";
          var parsedJson = jsonDecode(jsonContent);
          if (parsedJson['output'] != null) {
            allOutput.addAll(List<Map<String, dynamic>>.from(parsedJson['output']));
          }
        } else {
          return null;
        }
      }

       return allOutput;
    } catch (e) {
      print("An error occurred while generating the to-do list: $e");
      throw Exception("An error occurred while generating the to-do list");
    }
  }
}