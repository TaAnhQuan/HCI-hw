import 'dart:convert';
import 'package:app/constants/prompt_constants.dart';
import 'package:app/models/record_entity.dart';
import 'package:app/models/summary_entity.dart';
import 'package:app/models/todo_entity.dart';
import 'package:app/services/embeddings_service.dart';
import 'package:app/services/llm.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:app/services/todo_manager.dart';
import 'package:intl/intl.dart';

import 'notification.dart';

class DialogueSummary {
  // MainProcess, start the summarization process
  static Future<void> start({bool isMeeting=false, int? startMeetingTime}) async {
    try {
      int? startSummaryTime = 0;
      if (isMeeting) {
        if (startMeetingTime == null || (DateTime.now().millisecondsSinceEpoch - startMeetingTime < 1 * 60 * 1000)) {
          return;
        }
        startSummaryTime = startMeetingTime;
      } else {
        int? endTime = ObjectBoxService().getLastRecord()?.createdAt;
        if (endTime == null || (!isMeeting && DateTime.now().millisecondsSinceEpoch - endTime < 3 * 60 * 1000)) {
          return;
        }

        if (!ObjectBoxService.summaryBox.isEmpty()) {
          startSummaryTime = ObjectBoxService().getLastSummary(isMeeting: isMeeting)?.endTime;
        }
      }

      Embeddings embeddings = await Embeddings.create();

      // Generate summary
      var summary = await _summarize(startSummaryTime!, isMeeting: isMeeting);
      if (summary != null) {
        var jsonResults = jsonDecode(summary);
        List<dynamic> summaryArray = jsonResults["output"];
        List<SummaryEntity> summaryEntities = [];

        // Process each item in the summary array
        for (var item in summaryArray) {
          String subject = item['subject'];
          String abstract = item['abstract'].toString();
          int startTime = DateFormat("yyyy-MM-dd HH:mm").parse(item['start_time']).millisecondsSinceEpoch;
          int endTime = DateFormat("yyyy-MM-dd HH:mm").parse(item['end_time']).millisecondsSinceEpoch;
          List<double>? vector = await embeddings.getEmbeddings(subject);

          summaryEntities.add(SummaryEntity(subject: subject, content: abstract, vector: vector, startTime: startTime, endTime: endTime, createdAt: DateTime.now().millisecondsSinceEpoch, isMeeting: isMeeting));
        }

        // Insert the summary entities into the ObjectBox database
        await ObjectBoxService().insertSummaries(summaryEntities);
        if (isMeeting) {
          showNotificationOfSummaryFinished();
        }
      }
    } catch (e) {
      print("An error occurred while processing the summary: $e");
      showNotificationOfSummaryFailed();
      throw Exception("An error occurred while processing the summary");
    }
  }

  // Method to generate a summary using the LLM
  static Future<String?> _summarize(int startTime, {bool isMeeting=false}) async {
    List<RecordEntity>? listRecords = isMeeting 
        ? ObjectBoxService().getMeetingRecordsByTimeRange(startTime, DateTime.now().millisecondsSinceEpoch) 
        : ObjectBoxService().getRecordsByTimeRange(startTime, DateTime.now().millisecondsSinceEpoch);
    
    if (listRecords == null) { 
      return null; 
    }
    
    int contentLength = 0;
    StringBuffer chatHistoryBuffer = StringBuffer();
    for (RecordEntity record in listRecords) {
      contentLength += record.content!.length;
      String formattedTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(record.createdAt!));
      chatHistoryBuffer.write("($formattedTime) ${record.role}: ${record.content}\n");
    }

    if (contentLength < 1000 && (!isMeeting || contentLength < 10) ) {
      return null;
    }

    final chatHistory = chatHistoryBuffer.toString();

    if (!isMeeting) {
      try {
        LLM summaryLlm = await LLM.create('gpt-4o-mini', systemPrompt: systemPromptOfSummary);
        String summary = await summaryLlm.createRequest(content: getUserPromptOfSummaryGeneration(chatHistory));
        print("Initial summary: $summary");

        summaryLlm.setSystemPrompt(systemPrompt: systemPromptOfSummaryReflection);
        String comments = await summaryLlm.createRequest(content: getUserPromptOfSummaryReflectionGeneration(chatHistory, summary));
        print("Feedback: $comments");

        summaryLlm.setSystemPrompt(systemPrompt: systemPromptOfNewSummary);
        summary = await summaryLlm.createRequest(content: getUserPromptOfNewSummaryGeneration(chatHistory, summary, comments));
        print("Revised summary: $summary");

        return summary;
      } catch (e) {
        print("An error occurred while generating the summary: $e");
        throw Exception("An error occurred while generating the summary");
      }
    } else {
      try {
        List<String> chunks = [];
        await _splitChatHistory(chatHistory, 5000, 1000).forEach((chunk) {
          chunks.add(chunk);
        });

        LLM summaryLlm = await LLM.create('gpt-4o', systemPrompt: systemPromptOfMeetingSummary);

        List<String> summaries = await _getSummariesForChunks(summaryLlm, chunks);
        summaryLlm.setSystemPrompt(systemPrompt: systemPromptOfMeetingMerge);
        String summary = await _mergeSummaries(summaryLlm, summaries);
        summary = """{
  "output": [
    {
      "subject": "Meeting",
      "start_time": "${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(startTime))}",
      "end_time": "${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(listRecords.last.createdAt!))}",
      "abstract": ${jsonEncode(_extractJsonContent(summary))}
    }
  ]
}""";

        return summary;
      } catch (e) {
        print("An error occurred while generating the meeting summary: $e");
        showNotificationOfSummaryFailed();
        throw Exception("An error occurred while generating the meeting summary");
      }
    }
  }

  static Stream<String> _splitChatHistory(String chatHistory, int chunkSize, int overlap) async* {
    int length = chatHistory.length;
    int start = 0;

    while (start < length) {
      int end = start + chunkSize;
      if (end > length) end = length;
      yield chatHistory.substring(start, end);
      if (end == length) break;
      start = end - overlap;
    }
  }

  static Future<List<String>> _getSummariesForChunks(LLM summaryLlm, List<String> chunks) async {
    List<Future<String>> futureSummaries = [];

    for (String chunk in chunks) {
      Future<String> summaryFuture = summaryLlm.createRequest(content: chunk);
      futureSummaries.add(summaryFuture);
    }

    List<String> summaries = await Future.wait(futureSummaries);

    return summaries;
  }
  
  static Future<String> _mergeSummaries(LLM summaryLlm, List<String> summaries) async {
    String summary = await summaryLlm.createRequest(content: summaries.toString());
    final todo_list = jsonDecode(summary)['key_points'];
    _saveTodos(todo_list);
    return summary;
  }

  static Future<void> _saveTodos(List<dynamic> todoList) async {
    List<TodoEntity> todos = [];
    for (final todo in todoList) {
      todos.add(TodoEntity(task: todo['description'], deadline: todo['deadline'].toDateTime()!.fromMillisecondsSinceEpoch, detail: ''));
    }

    await ObjectBoxService().createTodos(todos);
  }

  static String _extractJsonContent(String input) {
    final regex = RegExp(r'```json([\s\S]*?)```');
    final match = regex.firstMatch(input);

    if (match != null) {
      return match.group(1)!.trim();
    } else {
      return input.trim();
    }
  }

}
