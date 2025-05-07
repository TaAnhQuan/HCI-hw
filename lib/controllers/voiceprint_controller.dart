import 'dart:async';
import 'dart:math';

import 'package:app/constants/wakeword_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../constants/voice_constants.dart';
import '../utils/text_utils.dart';

class WelcomeRecordController extends ChangeNotifier {
  final VoidCallback? onSetupComplete;
  Color feedbackColor = Colors.black;

  WelcomeRecordController({this.onSetupComplete});
  bool isSpeaking = false;
  bool isRecording = false;
  String recognitionFeedback = "";
  bool isEnd = false;
  int currentStep = 0;

  Timer? _feedbackTimer;

  Future<void> init() async {
    // Start recording automatically
    isRecording = true;
    notifyListeners();

    // Register a callback to handle task data
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  void _onReceiveTaskData(Object? data) {
    if (data is Map<String, dynamic>) {
      final isVadDetected = data['isVadDetected'] as bool?;

      if (isVadDetected!=null && isVadDetected != isSpeaking) {
        isSpeaking = isVadDetected;
        notifyListeners();
      }

      if (data.containsKey('isEndpoint')) {
        final isEndpoint = data['isEndpoint'] as bool?;

        if (currentStep == wakeword_constants.welcomePhrases.length - 1 && isEndpoint == true) {
          _completeSetup();
          return;
        }
      }

      if (currentStep < wakeword_constants.welcomePhrases.length - 1 && data.containsKey('status')) {
        final status = data['status'] as String?;
        if (status == 'success') {
          _advanceToNextStep();
        } else if (status == 'failure') {
          isSpeaking = false;
          notifyListeners();
          _showFeedback('Try again with the correct phrase.');
        }
      }
    }
  }

  void _advanceToNextStep() {
    if (currentStep < wakeword_constants.welcomePhrases.length - 1) {
      currentStep++;
      _showFeedback('Great! Moving to the next phrase.');
    }
    isSpeaking = false;
    notifyListeners();
  }

  void _completeSetup() {
    _showFeedback('Well done! Setup complete.');
    isRecording = false;
    FlutterForegroundTask.sendDataToTask(voice_constants.voiceprintDone);
    isSpeaking = false;
    notifyListeners();
    onSetupComplete?.call();
  }

  void _showFeedback(String feedback) {
    recognitionFeedback = feedback;
    if (feedback.contains('Great')) {
      feedbackColor = Colors.green;
    } else if (feedback.contains('Try again')) {
      feedbackColor = Colors.red;
    } else {
      feedbackColor = Colors.black; // Default color
    }
    notifyListeners();

    _feedbackTimer?.cancel();

    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      recognitionFeedback = '';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }
}