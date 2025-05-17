import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/chat_session.dart';
import '../models/record_entity.dart';
import '../services/llm.dart';
import '../services/objectbox_service.dart';


class ChatManager {
  final ChatSession chatSession = ChatSession();

  late LLM _llm;
  // late LLM _llm4SecondRound;

  // Receive ChatSession from external sources
  ChatManager();

  Future<void> init({required String selectedModel, String? systemPrompt}) async {
    _llm = await LLM.create(selectedModel, systemPrompt: systemPrompt);
    // _llm4SecondRound = await LLM.create(selectedModel, systemPrompt: systemPromptOfChat2);

    List<RecordEntity>? recentRecords = ObjectBoxService().getTermRecords();
    recentRecords?.forEach((RecordEntity recordEntity) {
      String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(recordEntity.createdAt!));
      addChatSession(recordEntity.role!, recordEntity.content!, time: formattedTime);
    });
  }

  Stream<String> createStreamingRequest({required String text}) async* {
    RegExp pattern = RegExp(r'[。！？；：.!?;:](?=\s)');

    var lastIndex = 0;
    var content = "";
    var jsonObj = {};

    var messages = [{"role": "user", "content": buildInput(text)}];

    final responseStream = _llm.createStreamingRequest(messages: messages);

    await for (var chunk in responseStream) {
      final jsonString = completeJsonIfIncomplete(chunk);
      try {
        jsonObj = jsonDecode(jsonString);

        if (jsonObj.containsKey('content')) {
          content = jsonObj['content'];

          Iterable<RegExpMatch> matches = pattern.allMatches(content);
          if (matches.isNotEmpty && matches.last.start + 1 > lastIndex) {

            final match = matches.last;
            final matchedText = match.group(0);

            final delta = content.substring(lastIndex, matches.last.start + 1);

            lastIndex = matches.last.start + 1;
            yield jsonEncode({
              "content": content,
              "delta": delta,
              "isFinished": false,
              "isEnd": jsonObj['isEnd'] ?? false,
            });
          }
        }
      } catch (e) {
        print("JSON string is incomplete, continue accumulating: $jsonString");
      }
    }

    if (lastIndex < content.length) {
      final remainingText = content.substring(lastIndex);
      yield jsonEncode({
        "content": content,
        "delta": remainingText,
        "isFinished": true,
        "isEnd": jsonObj['isEnd'] ?? false,
      });
    }

    // Second round of processing
    // if (jsonObj.containsKey('time') && jsonObj.containsKey('keywords')) {
    //   try {
    //     lastIndex = 0;
    //     int? queryTimeStamp;
    //     List<String> keywords = List<String>.from(jsonObj['keywords'].map((item) => item.toString()));
    //     List<SummaryEntity>? similarSummaries;
    //     try {
    //       if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$').hasMatch(jsonObj['time'])) {
    //         queryTimeStamp = DateFormat('yyyy-MM-dd HH:mm').parse(jsonObj['time']).millisecondsSinceEpoch;
    //         similarSummaries = await ObjectBoxService().getSimilarSummariesWithConstraints(keywords, 0.7, time: queryTimeStamp, level: 'mm');
    //       } else if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}$').hasMatch(jsonObj['time'])) {
    //         queryTimeStamp = DateFormat('yyyy-MM-dd HH').parse(jsonObj['time']).millisecondsSinceEpoch;
    //         similarSummaries = await ObjectBoxService().getSimilarSummariesWithConstraints(keywords, 0.7, time: queryTimeStamp, level: 'HH');
    //       } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(jsonObj['time'])) {
    //         queryTimeStamp = DateFormat('yyyy-MM-dd').parse(jsonObj['time']).millisecondsSinceEpoch;
    //         similarSummaries = await ObjectBoxService().getSimilarSummariesWithConstraints(keywords, 0.7, time: queryTimeStamp, level: 'dd');
    //       }
    //     } catch (e) {
    //       print('Error during parse date time: $e');
    //     }
    //
    //     String history = "";
    //     if (similarSummaries != null && similarSummaries.isNotEmpty) {
    //       history = loadChatHistory(similarSummaries.last.startTime, similarSummaries.last.endTime);
    //     }
    //
    //     final extraMessage = "Relative information: ${(similarSummaries != null && similarSummaries.isNotEmpty) ? similarSummaries.map((item) => item.content).toList() : ''}\nRelative chat history: $history";
    //     var messages2 = messages;
    //     messages2.removeAt(0);
    //     messages2.last["content"] = "${messages2.last["content"]!}\n$extraMessage";
    //     final responseStream = _llm4SecondRound.createStreamingRequest(messages: messages2);
    //     await for (var chunk in responseStream) {
    //       final jsonString = completeJsonIfIncomplete(chunk);
    //       try {
    //         jsonObj = jsonDecode(jsonString);
    //
    //         if (jsonObj.containsKey('content')) {
    //           content = jsonObj['content'];
    //
    //           Iterable<RegExpMatch> matches = pattern.allMatches(content);
    //           if (matches.isNotEmpty && matches.last.start + 1 > lastIndex) {
    //             final match = matches.last;
    //             final matchedText = match.group(0);
    //
    //             final delta = content.substring(lastIndex, matches.last.start + 1);
    //             lastIndex = matches.last.start + 1;
    //             yield jsonEncode({
    //               "content": content,
    //               "delta": delta,
    //               "isFinished": false,
    //               "isEnd": jsonObj['isEnd'] ?? false,
    //             });
    //           }
    //         }
    //       } catch (e) {
    //         print("JSON string is incomplete, continue accumulating: $jsonString");
    //       }
    //     }
    //   } catch (e) {
    //     print("Failed to parse query start and end time: $e");
    //   }
    //
    //   if (lastIndex < content.length) {
    //     final remainingText = content.substring(lastIndex);
    //     yield jsonEncode({
    //       "content": content,
    //       "delta": remainingText,
    //       "isFinished": true,
    //       "isEnd": jsonObj['isEnd'] ?? false,
    //     });
    //   }
    // }

    messages.add({"role": "assistant", "content": content});
    content = '';
  }

  Future<String> createRequest({required String text}) {
    final content = buildInput(text);
    return _llm.createRequest(content: content);
  }

  String buildInput(String userInput) {
    final session = loadChatSession();
    DateTime now = DateTime.now();
    var input = """
Timestamp: ${now.toIso8601String().split('.').first}\n
---\n
User Input: $userInput""";
    return input;
  }

  // Retrieve recent chat history
  List<Chat> getChatSession() {
    return chatSession.chatHistory.items;
  }

  // Update work status
  void updateWorkingState(String state) {
    chatSession.workingState = state;
  }

  // Clear chat history
  void clearChatHistory() {
    chatSession.chatHistory.clear();
  }

  // Delete chat records with a specified timestamp
  void removeChatByTime(int time) {
    chatSession.chatHistory.removeWhere((chat) => chat.time == time);
  }

  // Update chatHistory (e.g. when a user initiates a search)
  void updateChatHistory([List<Chat>? filteredChats]) {
    chatSession.chatHistory.clear();

    if (filteredChats != null && filteredChats.isNotEmpty) {
      for (var chat in filteredChats) {
        chatSession.chatHistory.add(chat);
      }
    } else {
      List<RecordEntity>? recentRecords = ObjectBoxService().getTermRecords();
      recentRecords?.forEach((RecordEntity recordEntity) {
        String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(recordEntity.createdAt!));
        addChatSession(recordEntity.role!, recordEntity.content!, time: formattedTime);
      });
    }
  }

  // Filter chat records based on roles
  void filterChatsByRole(String role) {
    chatSession.chatHistory = LimitedQueue<Chat>(chatSession.chatHistory.maxLength)
      ..addAll(chatSession.chatHistory.items.where((chat) => chat.role == role));
  }

  String loadChatHistory(queryStartTime, queryEndTime) {
    if (queryStartTime == 0 || queryEndTime == 0) {
      return '';
    }
    StringBuffer ret = StringBuffer();
    final historyList = ObjectBoxService().getChatRecordsByTimeRange(queryStartTime, queryEndTime);
    for (var history in historyList!) {
      // Append each chat record to the result string
      String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(history.createdAt!));
      ret.write("$formattedTime ${history.role}: ${history.content}\n");
    }
    return ret.toString();
  }

  String loadChatSession() {
    StringBuffer ret = StringBuffer();
    List<Chat> sessionList = getChatSession();

    if (sessionList.isNotEmpty) {
      for (var i = 0; i < sessionList.length - 1; i++) {
        var session = sessionList[i];
        ret.write("${session.time} ${session.role}: ${session.txt}\n");
      }
    }

    return ret.toString();
  }

  // Common method: Add a chat record
  void addChatSession(String role, String txt, {String? time}) {
    time ??= DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    Chat newChat = Chat(role: role, txt: txt, time: time);
    chatSession.chatHistory.add(newChat);
  }

  String completeJsonIfIncomplete(String jsonString) {
    if (jsonString.trim().endsWith('"}')) {
      return jsonString;
    } else if (jsonString.trim().endsWith('"')) {
      return '$jsonString}';
    } else if (jsonString.endsWith(',')) {
      return '${jsonString.substring(0, jsonString.length - 1)}}';
    } else {
      return '$jsonString"}';
    }
  }
}
