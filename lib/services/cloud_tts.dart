import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:app/utils/asr_utils.dart';
import 'package:logger/logger.dart' show Level;

import 'package:app/models/llm_config.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'latency_logger.dart';

class CloudTts {
  late String _openaiApiKey;
  static const String defaultBaseUrl = 'https://one-api.bud.inc/v1/audio/speech';

  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer(logLevel: Level.error);

  StreamController<String>? _textQueue = StreamController<String>();

  StreamSubscription? _responseSubscription;

  HttpClient? _httpClient;

  final endOfStreamMarker = Uint8List(0);

  bool get isAvailable => _openaiApiKey.isNotEmpty;

  Future<void> init() async {
    LlmConfigEntity? config = ObjectBoxService().getConfigsByProvider("OpenAI");
    if (config != null && config.apiKey != null && config.baseUrl != null) {
      _openaiApiKey = config.apiKey!;
    } else {
      _openaiApiKey = await FlutterForegroundTask.getData(key: 'llmToken');
    }
    if (Platform.isAndroid) {
      await _audioPlayer.openPlayer(isBGService: true);
    } else {
      await _audioPlayer.openPlayer();
    }
  }

  Future<void> _start({String? operationId}) async {
    log('Initializing OpenAI TTS streaming...');

    await _audioPlayer.startPlayerFromStream(
      sampleRate: 24000,
      codec: Codec.pcm16,
      interleaved: true,
      numChannels: 1,
      bufferSize: 8192
    );

    _processTextQueue();
  }

  Future<void> _processTextQueue() async {
    await for (final text in _textQueue!.stream) {
      log('Processing text: $text');
      try {
        await _streamTtsAudio(text);
      } catch (e) {
        log('Error while processing text: $e');
      }
    }
  }

  Future<void> _streamTtsAudio(String text) async {
    final url = Uri.parse(defaultBaseUrl);
    final requestBody = jsonEncode({
      "model": "tts-1",
      "voice": "nova",
      "input": text,
      "response_format": "pcm",
    });

    _httpClient = HttpClient();
    final request = await _httpClient!.postUrl(url);
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
    request.headers.set(HttpHeaders.authorizationHeader, "Bearer $_openaiApiKey");
    request.add(utf8.encode(requestBody));

    final response = await request.close();

    if (response.statusCode == 200) {
      // log('Receiving audio stream...');
      Uint8List? _remainingByte;
      _responseSubscription = response.listen(
        (chunk) async {
          List<int> processedChunk = [];
          if (_remainingByte != null) {
            processedChunk.add(_remainingByte![0]);
            processedChunk.add(chunk[0]);
            chunk = chunk.sublist(1);
            _remainingByte = null;
          }

          for (var i = 0; i + 1 < chunk.length; i += 2) {
            processedChunk.add(chunk[i]);
            processedChunk.add(chunk[i + 1] ^ 0x80);
          }

          if (chunk.length % 2 != 0) {
            _remainingByte = Uint8List.fromList([chunk.last]);
          }

          _audioPlayer.uint8ListSink?.add(Uint8List.fromList(chunk));
        },
        onError: (e) {
          log('Error receiving audio chunk: $e');
        },
        onDone: () {
          log('Audio stream completed');
        }
      );
    } else {
      log('Error: ${response.statusCode}');
      String responseBody = await response.transform(utf8.decoder).join();
      log('Response: $responseBody');
    }
  }

  Future<void> speak(String text, {String? operationId}) async {
    log('Sending text input...');
    _textQueue?.add(text);
    if (_audioPlayer.isStopped) {
      await _start(operationId: operationId);
    }
  }

  bool get isPlaying => _audioPlayer.isPlaying;

  void stop() {
    log('Stopping playback...');

    _responseSubscription?.cancel();
    _responseSubscription = null;

    _httpClient?.close(force: true);
    _httpClient = null;

    _audioPlayer.stopPlayer();

    _textQueue?.close();
    _textQueue = StreamController<String>();
  }
}
