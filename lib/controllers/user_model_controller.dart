import 'dart:convert';
import 'package:app/services/chat_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/record_entity.dart';
import '../services/objectbox_service.dart';

class UserModelController extends ChangeNotifier{
  final String _selectedModel = 'gpt-4o';
  late final ChatManager _chatManager;
  final List<Map<String, dynamic>> messages = [];
  late String _userModelSessionId;
  String personality = "No context to analyze";
  String hobbies = "No context to analyze";
  String habits = "No context to analyze";

  UserModelController() {
    _initialize();
  }

  String _generateUserModelSession(){
    String input = 'userModels';

    List<int> bytes = utf8.encode(input);
    Digest sha256Hash = sha256.convert(bytes);

    String hashHex = sha256Hash.toString();
    RegExp digitRegExp = RegExp(r'\d+');
    Iterable<RegExpMatch> matches = digitRegExp.allMatches(hashHex);
    String allDigits = matches.map((m) => m.group(0)).join();
    String last5Digits = allDigits.length >= 5
        ? allDigits.substring(allDigits.length - 5)
        : allDigits.padLeft(5, '0');

    var uuid = const Uuid();
    String uuidString = uuid.v4();

    String combinedString = '$last5Digits-$uuidString';

    return combinedString;
  }

  Future<void> _initialize() async{
    _chatManager = ChatManager();
    _chatManager.init(selectedModel: _selectedModel);
    _userModelSessionId = _generateUserModelSession();
  }

  Future<void> _sendMessage() async {
    String text = "The following text is about the user's conversation history and a description of him" +
        "Please update the description of him from the following three aspects based on the conversation history " +
        "1 personality " +
        "2 hobbies " +
        "3 habits";

    if (text.isNotEmpty) {
      messages.insert(0, {
        'id': _userModelSessionId,
        'text': text,
        'isUser': true,
      });
      notifyListeners();
      // _objectBoxService.insertDialogueRecord(RecordEntity(role: 'user', content: text));
      _chatManager.addChatSession('user', text);
      await _getBotResponse(text);
    }
  }

  Future<void> _getBotResponse(String userInput) async {
    try {
      notifyListeners();

      _chatManager.createStreamingRequest(text: userInput).listen((jsonString) {
        print("Received JSON string: $jsonString");
        _handleReturnJsonData(jsonString);
      },
        onDone: () {},
        onError: (error) {
          print('Error: ${error.toString()}');
        },
      );
    } catch (e) {
      print("Catch error _getBotResponse()");
      print('Error: ${e.toString()}');
      messages.insert(0,{
        'id': Uuid().v4(),
        'text': 'Error: ${e.toString()}',
        'isUser': false
      });
      notifyListeners();
    }
  }

  void _handleReturnJsonData(String jsonString) {
    try {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      String content = jsonMap['content'];

      RegExp personalityRegExp = RegExp(r'1\.\s\*\*Personality\*\*:\s(.+?)(?=\n\n|$)', dotAll: true);
      RegExp hobbiesRegExp = RegExp(r'2\.\s\*\*Hobbies\*\*:\s(.+?)(?=\n\n|$)', dotAll: true);
      RegExp habitsRegExp = RegExp(r'3\.\s\*\*Habits\*\*:\s(.+?)(?=\n\n|$)', dotAll: true);

      bool updated = false;

      var personalityMatch = personalityRegExp.firstMatch(content);
      if (personalityMatch != null) {
        personality = personalityMatch.group(1)!.trim();
        updated = true;
      }

      var hobbiesMatch = hobbiesRegExp.firstMatch(content);
      if (hobbiesMatch != null) {
        hobbies = hobbiesMatch.group(1)!.trim();
        updated = true;
      }

      var habitsMatch = habitsRegExp.firstMatch(content);
      if (habitsMatch != null) {
        habits = habitsMatch.group(1)!.trim();
        updated = true;
      }

      if (updated) {
        notifyListeners();
      }
    } catch (e) {
      print("Error handling JSON data: $e");
    }
  }

  void updateUserDescription(){
    _sendMessage();
  }
}