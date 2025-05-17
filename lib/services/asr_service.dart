import 'dart:developer' as dev;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/constants/wakeword_constants.dart';
import 'package:app/services/tts_service_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import '../constants/prompt_constants.dart';
import '../constants/record_constants.dart';
import '../models/record_entity.dart';
import '../services/objectbox_service.dart';
import '../services/chat_manager.dart';

import '../utils/asr_utils.dart';
import '../utils/text_process_utils.dart';
import 'asr_service_isolate.dart';

final Float32List silence = Float32List((16000 * 5).toInt());

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

class RecordServiceHandler extends TaskHandler {
  AudioRecorder _record = AudioRecorder();
  sherpa_onnx.VoiceActivityDetector? _vad;
  late KeywordSpotter _keywordSpotter;
  late OnlineStream _keywordSpotterStream;
  StreamSubscription<RecordState>? _recordSub;
  final ObjectBoxService _objectBoxService = ObjectBoxService();

  bool _inDialogMode = false;
  bool _isInitialized = false;
  RecordState _recordState = RecordState.stop;
  bool _isMeeting = false;
  bool _onRecording = true;

  final ChatManager _chatManager = ChatManager();
  final String _selectedModel = 'qwen-max';
  bool _kwsBuddie = false;
  bool _kwsJustListen = false;
  List<double> samplesFloat32Buffer = [];
  StreamSubscription? _currentSubscription;
  Stream<Uint8List>? _recordStream;
  bool _onMicrophone = false;
  AsrServiceIsolate _asrServiceIsolate = AsrServiceIsolate();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await ObjectBoxService.initialize();

    await _chatManager.init(
        selectedModel: _selectedModel,
        systemPrompt:
        '$systemPromptOfChat\n\n${systemPromptOfScenario['voice']}');

    final isAlwaysOn = (await FlutterForegroundTask.getData(key: 'isRecording')) ?? true;
    if (isAlwaysOn) {
      await _startRecord();
    }
    IsolateTts.init();
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
    } else if (data == "InitTTS") {
      try {
        IsolateTts.init();
      } catch (e, stack) {
        print("TTS has Init $e");
      }
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

  Future<void> _initAsr() async {
    if (!_isInitialized) {
      sherpa_onnx.initBindings();

      _vad = await initVad();
      _keywordSpotter = await initKeywordSpotter();
      _keywordSpotterStream = _keywordSpotter.createStream();

      await _asrServiceIsolate.init();

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
    if (_vad == null || !_asrServiceIsolate.isInitialized) {
      return;
    }

    final samplesFloat32 = convertBytesToFloat32(Uint8List.fromList(data));

    _vad!.acceptWaveform(samplesFloat32);
    _keywordSpotterStream.acceptWaveform(samples: samplesFloat32, sampleRate: 16000);
    while (_keywordSpotter.isReady(_keywordSpotterStream)) {
      _keywordSpotter.decode(_keywordSpotterStream);
      final text = _keywordSpotter.getResult(_keywordSpotterStream).keyword;
      if (text.isNotEmpty) {
        if (wakeword_constants.wakeWordStartDialog
            .any((keyword) => text.toLowerCase().contains(keyword))) {
          _kwsBuddie = true;
        } else if (wakeword_constants.wakeWordEndDialog
            .any((keyword) => text.toLowerCase().contains(keyword))) {
          _kwsJustListen = true;
        } else {
        }
      }
    }

    if (_vad!.isDetected() && _inDialogMode) {
      _currentSubscription?.cancel();
      IsolateTts.interrupt();
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
      Float32List paddedSamples = await _addSilencePadding(samples);

      var segment = '';
      segment = await _asrServiceIsolate.sendData(paddedSamples);
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

    text = text.trim();
    text = TextProcessUtils.removeBracketsContent(text);
    text = TextProcessUtils.clearIfRepeatedMoreThanFiveTimes(text);
    text = text.trim();

    if (text.isEmpty) {
      return;
    }

    FlutterForegroundTask.sendDataToMain({
      'text': text,
      'isEndpoint': true,
      'inDialogMode': _inDialogMode,
      'isMeeting': _isMeeting,
      'speaker': speaker,
    });

    if (!_inDialogMode &&
        speaker == 'user' &&
        (wakeword_constants.wakeWordStartDialog
            .any((keyword) => text.toLowerCase().contains(keyword)) || _kwsBuddie)) {
      _kwsBuddie = false;
      _kwsJustListen = false;
      _inDialogMode = true;
      AudioPlayer().play(AssetSource('audios/interruption.wav'));
    }

    if (_inDialogMode) {
      _objectBoxService
          .insertDialogueRecord(RecordEntity(role: 'user', content: text));
      _chatManager.addChatSession('user', text);
      if (wakeword_constants.wakeWordEndDialog
          .any((keyword) => text.toLowerCase().contains(keyword)) || _kwsJustListen) {
        _inDialogMode = false;
        _kwsJustListen = false;
        _kwsBuddie = false;
        _vad!.clear();
        IsolateTts.interrupt();
        AudioPlayer().play(AssetSource('audios/beep.wav'));
      }
    } else {
      _objectBoxService
          .insertDefaultRecord(RecordEntity(role: 'user', content: text));
      _chatManager.addChatSession('user', text);
    }


    if (_inDialogMode) {
      _currentSubscription?.cancel();
      String ttsOperationId = Uuid().v4();
      _currentSubscription =
          _chatManager.createStreamingRequest(text: text).listen((response) {
            final res = jsonDecode(response);
            final content = res['content'] ?? res['delta'];
            final isFinished = res['isFinished'];


            FlutterForegroundTask.sendDataToMain({
              'currentText': text,
              'isFinished': false,
              'content': res['delta'],
            });
            IsolateTts.speak(text: res['delta'], operationId: ttsOperationId);

            if (isFinished) {
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

  Future<sherpa_onnx.VoiceActivityDetector> initVad() async =>
      sherpa_onnx.VoiceActivityDetector(
        config: sherpa_onnx.VadModelConfig(
          sileroVad: sherpa_onnx.SileroVadModelConfig(
            model: await copyAssetFile('assets/silero_vad.onnx'),
            minSilenceDuration: 0.6,
            minSpeechDuration: 0.25,
            maxSpeechDuration: 12.0,
          ),
          numThreads: 1,
          debug: true,
        ),
        bufferSizeInSeconds: 12.0,
      );

  Future<KeywordSpotter> initKeywordSpotter() async {
    const kwsDir = 'assets/sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01';
    const encoder = 'encoder-epoch-12-avg-2-chunk-16-left-64.onnx';
    const decoder = 'decoder-epoch-12-avg-2-chunk-16-left-64.onnx';
    const joiner = 'joiner-epoch-12-avg-2-chunk-16-left-64.onnx';
    KeywordSpotter kws =  KeywordSpotter(
        KeywordSpotterConfig(
          model: OnlineModelConfig(
              transducer: OnlineTransducerModelConfig(
                encoder: await copyAssetFile('$kwsDir/$encoder'),
                decoder: await copyAssetFile('$kwsDir/$decoder'),
                joiner: await copyAssetFile('$kwsDir/$joiner'),
              ),
              tokens: await copyAssetFile('$kwsDir/tokens_kws.txt')
          ),
          keywordsFile: await copyAssetFile('$kwsDir/keywords.txt'),
        )
    );
    return kws;
  }

  Future<Float32List> _addSilencePadding(Float32List samples) async {
    int totalLength = silence.length * 2 + samples.length;

    Float32List paddedSamples = Float32List(totalLength);

    paddedSamples.setAll(silence.length, samples);

    return paddedSamples;
  }
}