import 'dart:async';
import 'dart:convert';

import 'package:app/constants/prompt_constants.dart';
import 'package:app/extension/map_extension.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../constants/voice_constants.dart';
import '../models/record_entity.dart';
import '../services/chat_manager.dart';
import 'package:uuid/uuid.dart';
import '../services/objectbox_service.dart';

class ChatController extends ChangeNotifier{

  late final ChatManager chatManager;
  final String _selectedModel = 'qwen-max';
  final ObjectBoxService _objectBoxService = ObjectBoxService();
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController textController = TextEditingController();
  final Function onNewMessage;
  final ScrollController scrollController = ScrollController();
  Map<String, String?> userToResponseMap = {};

  int _currentPage = 0;
  int countHelp = 0;
  static const int _pageSize = 10;
  bool isLoading = false;
  bool hasMoreMessages = true;

  ChatController({required this.onNewMessage}) {
    _initialize();
  }

  Future<void> _initialize() async {
    chatManager = ChatManager();
    chatManager.init(selectedModel: _selectedModel);

    await loadMoreMessages(reset: true);
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  Future<void> loadMoreMessages({bool reset = false}) async {
    if (isLoading) return;

    isLoading = true;

    if (reset) {
      _currentPage = 0;
      messages.clear();
      hasMoreMessages = true;
      chatManager.updateChatHistory();
    }

    List<RecordEntity>? records = _objectBoxService.getChatRecords(
      offset: messages.length,
      limit: _pageSize,
    );

    if (records != null && records.isNotEmpty) {
      _currentPage++;
      List<Map<String, dynamic>> newMessages = records.map((record) {
        return {
          'id': Uuid().v4(),
          'text': record.content,
          'isUser': record.role,
        };
      }).toList();

      messages.insertAll(messages.length, newMessages);
      if (reset) {
        refreshCount++;
      }
      tryNotifyListeners();
    } else {
      hasMoreMessages = false;
    }

    isLoading = false;
  }

  int refreshCount = 0;

  Timer? _typingTimer;

  void startTypingAnimation() {
    if (_typingTimer == null || !_typingTimer!.isActive) {
      _typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (messages.isEmpty) {
          messages.insert(0, {
            'id': 'typing_placeholder',
            'text': '.',
            'isUser': 'user',
          });
          return;
        }
        if (messages.isNotEmpty && messages[0]['id'] == 'typing_placeholder') {
          messages[0].moveToNextDot();
        } else if (messages.isEmpty || (messages.isNotEmpty && messages[0]['id'] != 'typing_placeholder')) {
          messages.insert(0, {
            'id': 'typing_placeholder',
            'text': '.',
            'isUser': 'user',
          });
        }
        tryNotifyListeners();
      });
    }
  }

  void stopTypingAnimation() {
    _typingTimer?.cancel();
    _typingTimer = null;
  }

  void _onReceiveTaskData(Object data) {
    if (data == 'refresh'){
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
        startTypingAnimation();
      } else if (isSpeaking != null && !isSpeaking) {
        stopTypingAnimation();
        int typingIndex = messages.indexWhere((msg) => msg['id'] == 'typing_placeholder');
        if (typingIndex != -1) {
          messages.removeAt(typingIndex);
          tryNotifyListeners();
        }
      }

      if (isEndpoint != null && text != null && isMeeting != null && inDialogMode != null && !isMeeting  && !inDialogMode!) {
        int typingIndex = messages.indexWhere((msg) => msg['id'] == 'typing_placeholder');
        if (typingIndex != -1) {
          stopTypingAnimation();
          messages.removeAt(typingIndex);
        }
        messages.insert(0, {
          'id': const Uuid().v4(),
          'text': text,
          'isUser': speaker,
        });
        tryNotifyListeners();
      }

      if (isEndpoint != null && text != null && isMeeting != null && isMeeting) {
        int typingIndex = messages.indexWhere((msg) => msg['id'] == 'typing_placeholder');
        if (typingIndex != -1) {
          stopTypingAnimation();
          messages.removeAt(typingIndex);
        }
        messages.insert(0, {
          'id': const Uuid().v4(),
          'text': text,
          'isUser': 'user',
        });
        tryNotifyListeners();
        countHelp = countHelp + 1;
        if (countHelp == 6) {
          chatManager.updateChatHistory();
          sendMessage(initialText: systemPromptOfHelp);
          countHelp = 0;
        }
      }

      if (isEndpoint != null && text != null && inDialogMode != null && inDialogMode) {
        int typingIndex = messages.indexWhere((msg) => msg['id'] == 'typing_placeholder');

        if (isEndpoint == true) {
          if (typingIndex != -1) {
            stopTypingAnimation();
            messages.removeAt(typingIndex);
          }
          String userInputId = const Uuid().v4();
          messages.insert(0, {
            'id': userInputId,
            'text': text,
            'isUser': 'user',
          });
          userToResponseMap[userInputId] = null;
          tryNotifyListeners();
        }
      }

      if (isFinished != null && delta != null) {
        int userIndex = messages.indexWhere((msg) => msg['text'] == currentText && msg['isUser'] == 'user');

        if (userIndex != -1) {
          String? responseId = userToResponseMap[messages[userIndex]['id']];

          if (responseId == null) {
            responseId = const Uuid().v4();
            userToResponseMap[messages[userIndex]['id']] = responseId;
            messages.insert(0,{
              'id': responseId,
              'text': '',
              'isUser': 'assistant',
            });
          }

          int botIndex = messages.indexWhere((msg) => msg['id'] == responseId);
          if (botIndex != -1) {
            messages[botIndex]['text'] += "$delta ";
            tryNotifyListeners();

            if (isFinished) {
              messages[botIndex]['text'] = messages[botIndex]['text'].trim();
              userToResponseMap.remove(messages[userIndex]['id']);
            }
          }
        }
      }
    }
  }

  tryNotifyListeners(){
    onNewMessage();
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> sendMessage({String? initialText}) async {
    String text = initialText ?? textController.text;
    String displayText;

    if (text.isNotEmpty) {
      textController.clear();
      if (text == systemPromptOfHelp) {
        displayText = "Help me Buddie.";
        chatManager.updateChatHistory();
      } else {
        displayText = text;
      }
      messages.insert(0, {
        'id': const Uuid().v4(),
        'text': displayText,
        'isUser': 'user',
      });
      tryNotifyListeners();
      _objectBoxService.insertDialogueRecord(RecordEntity(role: 'user', content: displayText));
      _scrollToBottom();

      chatManager.addChatSession('user', displayText);
      await _getBotResponse(text);
    }
  }

  Future<void> _getBotResponse(String userInput) async {
    try {
      tryNotifyListeners();

      String? responseId;

      chatManager.createStreamingRequest(text: userInput).listen((jsonString) {
          try {
            final jsonObj = jsonDecode(jsonString);

            if (responseId == null) {
              responseId = const Uuid().v4();
              messages.insert(0,{'id': responseId, 'text': '', 'isUser': 'assistant'});
            }

            if (jsonObj.containsKey('delta')) {
              final delta = jsonObj['delta'];
              updateMessageText(responseId!, delta);
            }

            if (jsonObj['isFinished'] == true) {
              final completeResponse = jsonObj['content'];
              updateMessageText(responseId!, completeResponse, isFinal: true);
              responseId = null;

              _objectBoxService.insertDialogueRecord(RecordEntity(role: 'assistant', content: completeResponse));
              chatManager.addChatSession('assistant', completeResponse);
            }
          } catch (e) {
            updateMessageText(responseId!, 'Error parsing response');
          }
        },
        onDone: () {},
        onError: (error) {
          if (responseId != null) {
            updateMessageText(responseId!, 'Error: ${error.toString()}');
          } else {
            messages.insert(0, {'id': const Uuid().v4(), 'text': 'Error: ${error.toString()}', 'isUser': 'assistant'});
          }
          tryNotifyListeners();
        },
      );
    } catch (e) {
      messages.insert(0,{
        'id': Uuid().v4(),
        'text': 'Error: ${e.toString()}',
        'isUser': 'assistant'
      });
      tryNotifyListeners();
    }
  }

  void updateMessageText(String messageId, String text, {bool isFinal = false}) {
    int index = messages.indexWhere((msg) => msg['id'] == messageId);
    if (index != -1) {
      if (!isFinal) {
        messages[index]['text'] += text;
      } else {
        messages[index]['text'] = text;
      }
      tryNotifyListeners();
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

  void _scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(scrollController.hasClients){
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }else{
          dev.log(
            'No clients are attached to the ScrollController.',
            name: 'ScrollToBottomError',
            level: 500,
          );
        }
      });
  }

  bool checkAndNavigateToWelcomeRecordScreen() {
    final speakers = _objectBoxService.getUserSpeaker();
    int? userUtteranceCount = speakers?.length;

    if (userUtteranceCount! < 3) {
      _objectBoxService.deleteAllSpeakers();
      FlutterForegroundTask.sendDataToTask(voice_constants.voiceprintStart);
      return true;
    }
    return false;
  }
}
