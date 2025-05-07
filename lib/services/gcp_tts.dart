import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:app/services/objectbox_service.dart';
import 'package:flutter_sound/flutter_sound.dart' as flutter_sound;
import 'package:grpc/grpc.dart';
import 'package:app/src/generated/google/cloud/texttospeech/v1/cloud_tts.pbgrpc.dart';

import 'latency_logger.dart';


class GcpTts {
  String _gcpApiKey = ''; 

  ClientChannel? _channel;
  TextToSpeechClient? _client;

  final flutter_sound.FlutterSoundPlayer _audioPlayer = flutter_sound.FlutterSoundPlayer();

  StreamController<StreamingSynthesizeRequest>? _requestController;

  StreamController<Uint8List>? _feedQueue;
  StreamController<String>? _textQueue = StreamController<String>();

  StreamSubscription? _streamingSynthesizeSubscription;

  bool get isAvailable => _gcpApiKey.isNotEmpty;
  final endOfStreamMarker = Uint8List(0);

  void init() {
    _gcpApiKey = ObjectBoxService().getConfigsByProvider("GCP")?.apiKey ?? '';
  }

  Future<void> _start({String? operationId}) async {
    if (_channel != null || _client != null) {
      log('Already initialized.');
      return;
    }
    log('Initializing gRPC channel and client...');

    _feedQueue = StreamController<Uint8List>();

    _channel = ClientChannel('texttospeech.googleapis.com');
    _client = TextToSpeechClient(
      _channel!,
      options: CallOptions(
        metadata: {'X-goog-api-key': _gcpApiKey}, // 替换为实际 API Key
      ),
    );

    _requestController = StreamController<StreamingSynthesizeRequest>();

    _requestController!.add(StreamingSynthesizeRequest(
      streamingConfig: StreamingSynthesizeConfig(
        voice: VoiceSelectionParams(
          languageCode: 'en-US',
          name: 'en-US-Journey-F',
        ),
      ),
    ));

    _streamingSynthesizeSubscription = _client!.streamingSynthesize(_requestController!.stream).listen(
      (response) {
        if (response.hasAudioContent()) {
          log('Received audio content chunk...');
          if (operationId != null) {
            LatencyLogger.recordEnd(operationId, phase: 'tts');
          }
          _feedQueue!.add(Uint8List.fromList(response.audioContent));
        }
      },
      onError: (error) {
        log('Error during streaming: $error');
        // stop();
      },
      onDone: () {
        log('Streaming completed.');
        _feedQueue!.add(endOfStreamMarker);
        // stop();
      },
    );

    if (Platform.isAndroid) {
      await _audioPlayer.openPlayer(isBGService: true);
    } else {
      await _audioPlayer.openPlayer();
    }
    await _audioPlayer.startPlayerFromStream(
      sampleRate: 22050,
      codec: flutter_sound.Codec.pcm16,
      interleaved: true,
      numChannels: 1,
      bufferSize: 8192
      // whenFinished: () {
      //   log('Playback completed.');
      //   stop();
      // },
    );
    _processTextQueue();
    _processFeedQueue();
  }

  Future<void> _processTextQueue() async {
    await for (final text in _textQueue!.stream) {
      log('Processing text: $text');
      try {
        _requestController!.add(StreamingSynthesizeRequest(
          input: StreamingSynthesisInput(
            text: text,
          ),
        ));
      } catch (e) {
        log('Error while processing text: $e');
      }
    }
  }

  Future<void> _processFeedQueue() async {
    await for (final audioContent in _feedQueue!.stream) {
      if (audioContent == endOfStreamMarker) {
        log('Received end-of-stream marker. Closing feed queue...');
        stop();
        return;
      }
      try {
        log('audioContent.length: ${audioContent.length}');
        await _audioPlayer.feedFromStream(audioContent);
      } catch (e) {
        log('Error during feeding: $e');
      }
    }
  }

  Future<void> speak(String text, {String? operationId}) async {
    log('Sending text input...');
    _textQueue?.add(text);
    if (_channel == null || _client == null) {
      await _start(operationId: operationId);
    }
  }

  bool get isPlaying => _audioPlayer.isPlaying;

  void stop() {
    log('Stopping playback...');

    if (_channel == null) {
      log('Already stopped.');
      return;
    }

    _streamingSynthesizeSubscription?.cancel();

    _audioPlayer.closePlayer();
    _channel!.shutdown();
    _channel = null;
    _client = null;

    _requestController?.close();
    _requestController = null;

    _textQueue?.close();
    _feedQueue?.close();

    _textQueue = StreamController<String>();
    _feedQueue = StreamController<Uint8List>();
  }
}
