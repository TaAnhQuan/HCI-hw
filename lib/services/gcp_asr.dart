import 'package:app/services/objectbox_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_speech/google_speech.dart';
import 'dart:developer' as dev;
import 'dart:async';

class RecognitionResult {
  final String text;
  final bool isFinal;

  RecognitionResult(this.text, this.isFinal);
}

class GcpAsr {
  late final SpeechToText speechToText;

  BehaviorSubject<List<int>>? _onlineAudioStream;
  final List<List<int>> _audioCache = [];

  String _gcpApiKey = '';

  bool get isRecognizing => _onlineAudioStream != null;
  bool get isAvailable => _gcpApiKey.isNotEmpty;

  void init() {
    _gcpApiKey = ObjectBoxService().getConfigsByProvider("GCP")?.apiKey ?? '';
    speechToText = SpeechToText.viaApiKey(_gcpApiKey);
  }

  Stream<RecognitionResult> startRecognition() {
    if (isRecognizing) throw Exception("Recognition is already in progress.");

    _onlineAudioStream = BehaviorSubject<List<int>>();

    final responseStream = speechToText.streamingRecognize(
      StreamingRecognitionConfig(
        config: RecognitionConfig(
          encoding: AudioEncoding.LINEAR16,
          model: RecognitionModel.basic,
          enableAutomaticPunctuation: true,
          enableSpokenPunctuation: true,
          sampleRateHertz: 16000,
          languageCode: 'en-US',
        ),
        interimResults: true,
      ),
      _onlineAudioStream!,
    );

    for (var audioData in _audioCache) {
      _onlineAudioStream?.add(audioData);
    }
    _audioCache.clear();


    return responseStream.asyncExpand((response) async* { 
      if (response.results.isEmpty) return;

      final isFinal = response.results.last.isFinal;

      final currentText = response.results.map((e) => e.alternatives.first.transcript).join('');
      dev.log("Online Recognition result: ${currentText} | ${response.totalBilledTime}");

      yield RecognitionResult(currentText, isFinal);
    }).handleError((error) {
      dev.log("Recognition error: $error");
    }).doOnDone(() {
      dev.log("Recognition completed.");
      _stopAudioStream();
    }).where((event) => event != null).cast<RecognitionResult>();
  }

  void acceptWaveform(List<int> audioData) {
    if (isRecognizing) {
      _onlineAudioStream?.add(audioData);
    } else {
      _audioCache.add(audioData);
    }
  }

  void clearAudioStream() {
    _audioCache.clear();
    _onlineAudioStream?.close();
    _onlineAudioStream = null;
  }

  void stopRecognition() {
    if (!isRecognizing) return;
    _stopAudioStream();
  }

  void _stopAudioStream() {
    _onlineAudioStream?.close();
    _onlineAudioStream = null;
  }
}
