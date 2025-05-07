import 'dart:developer' as dev;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:app/constants/wakeword_constants.dart';
import 'package:app/services/cloud_asr.dart';
import 'package:app/services/cloud_tts.dart';
import 'package:app/services/latency_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/record_constants.dart';
import '../models/record_entity.dart';
import '../services/objectbox_service.dart';
import '../services/chat_manager.dart';

import '../utils/asr_utils.dart';
import 'package:my_record_service/my_record_service.dart';

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

class RecordServiceHandler extends TaskHandler {
  late AsrManager _asrManager;
  AudioRecorder _record = AudioRecorder();
  sherpa_onnx.VoiceActivityDetector? _vad;
  sherpa_onnx.OfflineRecognizer? _nonstreamRecognizer;
  StreamSubscription<RecordState>? _recordSub;
  final ObjectBoxService _objectBoxService = ObjectBoxService();

  bool _inDialogMode = false;
  bool _isUsingCloudServices = true;

  bool _isInitialized = false;

  RecordState _recordState = RecordState.stop;
  bool _isMeeting = false;
  bool _onRecording = true;

  late FlutterTts _flutterTts;
  final CloudTts _cloudTts = CloudTts();
  final CloudAsr _cloudAsr = CloudAsr();

  final ChatManager _chatManager = ChatManager();
  final String _selectedModel = 'qwen-max';
  List<double> samplesFloat32Buffer = [];
  StreamSubscription? _currentSubscription;
  Stream<Uint8List>? _recordStream;
  bool _onMicrophone = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await ObjectBoxService.initialize();

    await _chatManager.init(selectedModel: _selectedModel);

    final isAlwaysOn = (await FlutterForegroundTask.getData(key: 'isRecording')) ?? true;
    if (isAlwaysOn) {
      _asrManager = AsrManager();
      await _startRecord();
    }

    _initTts();

    await _cloudAsr.init();
    await _cloudTts.init();

    _isUsingCloudServices = _cloudAsr.isAvailable && _cloudTts.isAvailable;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onReceiveData(Object data) async {
    if (data == Constants.actionStartRecord) {
      await _startRecord();
    } else if (data == Constants.actionStopRecord) {
      await _stopRecord();
    } else if (data == 'startRecording') {
      _onRecording = true;
    } else if (data == 'stopRecording') {
      _onRecording = false;
    } else if (data == Constants.actionStopMicrophone) {
      await _stopMicrophone();
    } else if (data == Constants.actionStartMicrophone) {
      await _startMicrophone();
    }
    FlutterForegroundTask.sendDataToMain(Constants.actionDone);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _stopRecord();
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == Constants.actionStopRecord) {
      await _stopRecord();
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.stopService();
      }
    }
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);
    if (Platform.isAndroid) {
      await _flutterTts.setQueueMode(1);
    }
  }

  Future<void> _initAsr() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();

      _vad = await _asrManager.initVad();

      _nonstreamRecognizer = await _asrManager.createNonstreamingRecognizer();

      _recordSub = _record.onStateChanged().listen((recordState) {
        _recordState = recordState;
      });

      _isInitialized = true;
    }
  }

  Future<void> _startRecord() async {
    await _initAsr();

    _startMicrophone();

    FlutterForegroundTask.saveData(key: 'isRecording', value: true);
    // create stop action button
    FlutterForegroundTask.updateService(
      notificationText: 'Recording...',
      notificationButtons: [
        const NotificationButton(id: Constants.actionStopRecord, text: 'stop'),
      ],
    );
  }

  Future<void> _startMicrophone() async {
    if (_onMicrophone) return;
    _onMicrophone = true;
    if (_recordStream != null) return;
    const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1);

    _record = AudioRecorder();
    _recordStream = await _record.startStream(config);
    _recordStream?.listen((data) {
      if (!_onRecording) return;
      _processAudioData(data);
    });
  }

  void _processAudioData(data, {String category = RecordEntity.categoryDefault}) async {
    if (_vad == null || _nonstreamRecognizer == null) {
      return;
    }

    final samplesFloat32 = convertBytesToFloat32(Uint8List.fromList(data));

    _vad!.acceptWaveform(samplesFloat32);

    if (_vad!.isDetected() && _inDialogMode) {
      if (_isUsingCloudServices) {
        if (_cloudTts.isPlaying) {
          _cloudTts.stop();
          AudioPlayer().play(AssetSource('audios/interruption.wav'));
        }
      } else {
        _flutterTts.stop();
      }
    }

    if (_vad!.isDetected()) {
      FlutterForegroundTask.sendDataToMain({'isVadDetected': true});
    } else {
      FlutterForegroundTask.sendDataToMain({'isVadDetected': false});
    }

    var text = '';
    while (!_vad!.isEmpty()) {
      final samples = _vad!.front().samples;
      if (samples.length < _vad!.config.sileroVad.windowSize) {
        break;
      }
      _vad!.pop();

      var segment = '';
      if ((_inDialogMode || _isMeeting) && _isUsingCloudServices) {
        segment = await _cloudAsr.recognize(samples);
      } else {
        final nonstreamStream = _nonstreamRecognizer!.createStream();
        nonstreamStream.acceptWaveform(samples: samples, sampleRate: 16000);
        _nonstreamRecognizer!.decode(nonstreamStream);
        segment = _nonstreamRecognizer!.getResult(nonstreamStream).text;
        nonstreamStream.free();
      }
      segment = segment
          .replaceFirst('Buddy', 'Buddie')
          .replaceFirst('buddy', 'buddie');

      text += segment;
    }

    if (text.isNotEmpty) {
      _processFinalResult(text, 'user', category: category);
    }
  }

  void _processFinalResult(String text, String speaker,
      {String category = RecordEntity.categoryDefault, String? operationId}) {
    if (text.isEmpty) return;

    if (!_inDialogMode &&
        speaker == 'user' &&
        wakeword_constants.wakeWordStartDialog
            .any((keyword) => text.toLowerCase().contains(keyword))) {
      _inDialogMode = true;
    }

    String trimmedText = text.trim();
    if ((trimmedText.startsWith('(') && trimmedText.endsWith(')')) ||
        (trimmedText.startsWith('[') && trimmedText.endsWith(']'))) {
      return;
    }

    FlutterForegroundTask.sendDataToMain({
      'text': text,
      'isEndpoint': true,
      'inDialogMode': _inDialogMode,
      'isMeeting': _isMeeting,
      'speaker': 'user',
    });

    if (_inDialogMode) {
      _objectBoxService
          .insertDialogueRecord(RecordEntity(role: 'user', content: text));
      _chatManager.addChatSession('user', text);
      if (wakeword_constants.wakeWordEndDialog
          .any((keyword) => text.toLowerCase().contains(keyword))) {
        _inDialogMode = false;
        _vad!.clear();
        if (_isUsingCloudServices) {
          _cloudTts.stop();
        } else {
          _flutterTts.stop();
        }
        AudioPlayer().play(AssetSource('audios/beep.wav'));
      }
    } else {
      _objectBoxService
          .insertDefaultRecord(RecordEntity(role: 'user', content: text));
      _chatManager.addChatSession('user', text);
    }

    if (_inDialogMode) {
      _currentSubscription?.cancel();
      _currentSubscription =
          _chatManager.createStreamingRequest(text: text).listen((response) {
            final res = jsonDecode(response);
            final content = res['content'] ?? res['delta'];
            final isFinished = res['isFinished'];

            if (operationId != null) {
              LatencyLogger.recordEnd(operationId, phase: 'llm');
            }

            FlutterForegroundTask.sendDataToMain({
              'currentText': text,
              'isFinished': false,
              'content': res['delta'],
            });
            if (!_isUsingCloudServices) {
              _flutterTts.speak(res['delta']);
            }

            if (isFinished) {
              if (_isUsingCloudServices) {
                _cloudTts.speak(content, operationId: operationId);
              }
              _objectBoxService.insertDialogueRecord(
                  RecordEntity(role: 'assistant', content: content));
              _chatManager.addChatSession('assistant', content);
            }
          });
    }
  }

  Future<void> _stopRecord() async {
    if (_recordStream != null) {
      await _record.stop();
      await _record.dispose();
      _recordStream = null;
    }

    _recordSub?.cancel();
    _currentSubscription?.cancel();

    _vad?.free();

    _nonstreamRecognizer?.free();

    _isInitialized = false;

    FlutterForegroundTask.saveData(key: 'isRecording', value: false);
    FlutterForegroundTask.updateService(
        notificationText: 'Tap to return to the app');
  }

  Future<void> _stopMicrophone() async {
    if (!_onMicrophone) return;
    if (_recordStream != null) {
      await _record.stop();
      await _record.dispose();
      _recordStream = null;
      _onMicrophone = false;
    }
  }
}