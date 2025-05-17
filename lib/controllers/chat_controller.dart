import 'dart:async';
import 'dart:convert';

import 'package:app/constants/prompt_constants.dart';
import 'package:app/extension/map_extension.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/voice_constants.dart';
import '../models/record_entity.dart';
import '../services/chat_manager.dart';
import 'package:uuid/uuid.dart';
import '../services/objectbox_service.dart';

class ChatController extends ChangeNotifier {
  late final ChatManager chatManager;
  late final ChatManager chatHelp;
  final String _selectedModel = 'qwen-max';
  final String helpMessage = 'Based on historical information, I think the following may help you:\n\n';
  final ObjectBoxService _objectBoxService = ObjectBoxService();
  final List<Map<String, dynamic>> historyMessages = [];
  final List<Map<String, dynamic>> newMessages = [];
  final TextEditingController textController = TextEditingController();
  final Function onNewMessage;
  final ScrollController scrollController = ScrollController();
  Map<String, String?> userToResponseMap = {};
  late final WebSocketChannel _mcpChannel;
  final Map<int, Completer<String>> _pendingRequests = {};
  late final StreamSubscription _mcpSubscription;

  final ValueNotifier<Set<String>> unReadMessageId = ValueNotifier({});

  static const int _pageSize = 25;
  bool isLoading = false;
  bool hasMoreMessages = true;
  bool bleConnection = false;

  ChatController({required this.onNewMessage}) {
    _initialize();
  }

  Future<void> _initialize() async {
    chatManager = ChatManager();
    chatHelp = ChatManager();
    await chatManager.init(selectedModel: _selectedModel, systemPrompt: '$systemPromptOfChat\n\n${systemPromptOfScenario['text']}');
    await chatHelp.init(selectedModel: _selectedModel, systemPrompt:  systemPromptOfHelp);
    _mcpChannel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080'));
    _mcpSubscription = _mcpChannel.stream.listen((message) {
      final response = jsonDecode(message);
      final id = response['id'];
      final completer = _pendingRequests[id];
      if (completer != null) {
        if (response['error'] != null) {
          completer.complete('Error: ${response['error']['message']}');
        } else {
          final content = response['result']['content'][0]['text'];
          completer.complete(content);
        }
        _pendingRequests.remove(id);
      }
    });

    await loadMoreMessages(reset: true);
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  Future<String> _callMCPTool(String method, Map<String, dynamic> params) async {
    final requestId = DateTime.now().microsecondsSinceEpoch;
    final completer = Completer<String>();
    _pendingRequests[requestId] = completer;

    _mcpChannel.sink.add(jsonEncode({
      'jsonrpc': '2.0',
      'id': requestId,
      'method': method,
      'params': params,
    }));

    return await completer.future;
  }

  Future<void> loadMoreMessages({bool reset = false}) async {
    if (isLoading) return;

    isLoading = true;

    if (reset) {
      historyMessages.clear();
      newMessages.clear();
      hasMoreMessages = true;
      chatManager.updateChatHistory();
      chatHelp.updateChatHistory();
    }

    List<RecordEntity>? records = _objectBoxService.getChatRecords(
      offset: historyMessages.length + newMessages.length,
      limit: _pageSize,
    );

    if (records != null && records.isNotEmpty) {
      List<Map<String, dynamic>> loadMessages = records.map((record) {
        return {
          'id': Uuid().v4(),
          'text': record.content,
          'isUser': record.role,
        };
      }).toList();
      if (newMessages.isEmpty) {
        newMessages.insertAll(0, loadMessages.toList());
        tryNotifyListeners();
        firstScrollToBottom();
      } else {
        historyMessages.insertAll(0, loadMessages.reversed.toList());
      }
      tryNotifyListeners();
    } else {
      hasMoreMessages = false;
    }

    isLoading = false;
  }

  ValueNotifier<bool> isSpeakValueNotifier = ValueNotifier(false);

  void _onReceiveTaskData(Object data) {
    if (data == 'refresh') {
      loadMoreMessages(reset: true);
      return;
    }

    if (data is Map<String, dynamic>) {
      final text = data['text'] as String?;
      final currentText = data['currentText'] as String?;
      final speaker = data['speaker'] as String?;
      final isEndpoint = data['isEndpoint'] as bool?;
      final inDialogMode = data['inDialogMode'] as bool?;
      final isMeeting = data['isMeeting'] as bool?;
      final isFinished = data['isFinished'] as bool?;
      final delta = data['content'] as String?;
      final isSpeaking = data['isVadDetected'] as bool?;

      if (isSpeaking != null && isSpeaking) {
        isSpeakValueNotifier.value = true;
        if (!bleConnection) {
          FlutterForegroundTask.sendDataToMain({
            'connectionState': true
          });
          FlutterForegroundTask.sendDataToTask("InitTTS");
          bleConnection = true;
        }
      } else if (isSpeaking != null && !isSpeaking) {
        isSpeakValueNotifier.value = false;
        if (!bleConnection) {
          FlutterForegroundTask.sendDataToMain({
            'connectionState': true
          });
          FlutterForegroundTask.sendDataToTask("InitTTS");
          bleConnection = true;
        }
      }

      if (isEndpoint != null &&
          text != null &&
          isMeeting != null &&
          inDialogMode != null &&
          !isMeeting &&
          !inDialogMode!) {
        isSpeakValueNotifier.value = false;
        insertNewMessage({
          'id': const Uuid().v4(),
          'text': text,
          'isUser': speaker,
        });
      }

      if (isEndpoint != null &&
          text != null &&
          isMeeting != null &&
          isMeeting) {
        isSpeakValueNotifier.value = false;
        insertNewMessage({
          'id': const Uuid().v4(),
          'text': text,
          'isUser': speaker,
        });
      }

      if (isEndpoint != null &&
          text != null &&
          inDialogMode != null &&
          inDialogMode) {
        if(isEndpoint == true){
          isSpeakValueNotifier.value = false;
          String userInputId = const Uuid().v4();
          insertNewMessage({
            'id': userInputId,
            'text': text,
            'isUser': speaker,
          });
          userToResponseMap[userInputId] = null;
        }
      }

      if (isFinished != null && delta != null) {
        int userIndex = newMessages.indexWhere(
                (msg) => msg['text'] == currentText && msg['isUser'] == 'user');

        if (userIndex != -1) {
          String? responseId = userToResponseMap[newMessages[userIndex]['id']];
          bool isInBottom = checkInBottom();

          if (responseId == null) {
            responseId = const Uuid().v4();
            userToResponseMap[newMessages[userIndex]['id']] = responseId;
            newMessages.insert(0, {
              'id': responseId,
              'text': '',
              'isUser': 'assistant',
            });
          }

          int botIndex =
          newMessages.indexWhere((msg) => msg['id'] == responseId);
          if (botIndex != -1) {
            newMessages[botIndex]['text'] += "$delta ";
            tryNotifyListeners();

            if (isInBottom) {
              firstScrollToBottom();
            }
            if (isFinished) {
              newMessages[botIndex]['text'] =
                  newMessages[botIndex]['text'].trim();
              userToResponseMap.remove(newMessages[userIndex]['id']);
            }
          }
        }
      }
    }
  }

  tryNotifyListeners() {
    onNewMessage();
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> sendMessage({String? initialText}) async {
    String text = initialText ?? textController.text;

    if (text.isNotEmpty) {
      textController.clear();

      insertNewMessage({
        'id': const Uuid().v4(),
        'text': text,
        'isUser': 'user',
      });
      _objectBoxService.insertDialogueRecord(
          RecordEntity(role: 'user', content: text));
      firstScrollToBottom();

      chatManager.addChatSession('user', text);
      await _getBotResponse(text);
    }
  }

  Future<void> askHelp() async {
    String text = "Please help me";

    chatHelp.updateChatHistory();

    if (text.isNotEmpty) {
      textController.clear();

      insertNewMessage({
        'id': const Uuid().v4(),
        'text': 'Help me Buddie',
        'isUser': 'user',
      });
      _objectBoxService.insertDialogueRecord(
          RecordEntity(role: 'user', content: 'Help me Buddie'));
      firstScrollToBottom();

      chatManager.addChatSession('user', 'Help me Buddie');
      await _getBotResponse(text, isHelp: true);
    }
  }

  Future<void> _getBotResponse(String userInput, {bool isHelp = false}) async {
    try {
      tryNotifyListeners();

      String? responseId;

      final chatResponse = isHelp ? chatHelp : chatManager;

      chatResponse.createStreamingRequest(text: userInput).listen(
            (jsonString) async {
          try {
            final jsonObj = jsonDecode(jsonString);
            bool isInBottom = checkInBottom();

            if (responseId == null) {
              responseId = const Uuid().v4();
              if (isHelp) {
                newMessages.insert(
                    0, {'id': responseId, 'text': helpMessage, 'isUser': 'assistant'});
              } else{
                newMessages.insert(
                    0, {'id': responseId, 'text': '', 'isUser': 'assistant'});
              }
            }

            if (jsonObj.containsKey('delta')) {
              final delta = jsonObj['delta'];
              updateMessageText(responseId!, delta, isHelp: isHelp);
            }else if (jsonObj.containsKey['tool']){
              final tool = jsonObj['tool'];
              final args = jsonObj['args'] ?? {};
              final result = await _callMCPTool(tool, args);
              updateMessageText(responseId!, result);
            }

            if (jsonObj['isFinished'] == true) {
              final completeResponse = jsonObj['content'];
              updateMessageText(responseId!, completeResponse,
                  isFinal: true, isHelp: isHelp);
              responseId = null;

              _objectBoxService.insertDialogueRecord(RecordEntity(
                  role: 'assistant', content: completeResponse));
              chatManager.addChatSession('assistant', completeResponse);
            }
            if (isInBottom) {
              firstScrollToBottom();
            }
          } catch (e) {
            updateMessageText(responseId!, 'Error parsing response');
          }
        },
        onDone: () {},
        onError: (error) async {
          String errorInfo = error.toString();
          errorInfo = 'Your usage quota has been exhausted.';
          bool isInBottom = checkInBottom();
          if (responseId != null) {
            updateMessageText(responseId!, 'Error: $errorInfo');
          } else {
            newMessages.insert(0, {
              'id': const Uuid().v4(),
              'text': 'Error: $errorInfo',
              'isUser': 'assistant'
            });
          }
          tryNotifyListeners();
          if (isInBottom) {
            firstScrollToBottom();
          }
        },
      );
    } catch (e) {
      newMessages.insert(0, {
        'id': Uuid().v4(),
        'text': 'Error: ${e.toString()}',
        'isUser': 'assistant'
      });

      tryNotifyListeners();
    }
  }

  void updateMessageText(String messageId, String text,
      {bool isFinal = false, bool isHelp = false}) {
    int index = newMessages.indexWhere((msg) => msg['id'] == messageId);
    if (index != -1) {
      if (!isFinal) {
        newMessages[index]['text'] += text;
      } else {
        newMessages[index]['text'] = isHelp ? helpMessage + text : text;
      }
      tryNotifyListeners();
    }
  }

  void insertNewMessage(Map<String, dynamic> data) {
    bool isInBottom = checkInBottom();
    if(!isInBottom){
      unReadMessageId.value.add(data['id']);
    }
    newMessages.insert(0, data);
    tryNotifyListeners();
    if (isInBottom) {
      firstScrollToBottom();
    }
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void dispose() {
    super.dispose();
    textController.dispose();
    scrollController.dispose();
  }

  bool isInAnimation = false;

  bool checkInBottom() {
    if (!scrollController.hasClients) return true;
    double maxScroll = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.offset;
    return currentScroll >= maxScroll - 20;
  }

  firstScrollToBottom({bool isAnimated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!scrollController.hasClients) return;
      if (isInAnimation) return;
      isInAnimation = true;
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.offset;
      while (currentScroll < maxScroll) {
        if (isAnimated) {
          // Perform the animated scroll only on the first call
          await scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
          await Future.delayed(const Duration(milliseconds: 10));
        } else {
          // Perform an immediate jump to the bottom on subsequent recursive calls
          scrollController.jumpTo(maxScroll);
        }
        maxScroll = scrollController.position.maxScrollExtent;
        currentScroll = scrollController.offset;
      }
      isInAnimation = false;
    });
  }
}