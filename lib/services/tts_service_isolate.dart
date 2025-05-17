import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flutter_sound.dart';

class _IsolateTask<T> {
  final SendPort sendPort;
  RootIsolateToken? rootIsolateToken;

  _IsolateTask(this.sendPort, this.rootIsolateToken);
}

class _PortModel {
  final String method;
  final SendPort? sendPort;
  dynamic data;

  _PortModel({
    required this.method,
    this.sendPort,
    this.data,
  });
}

class _TtsManager {
  final ReceivePort receivePort;
  final Isolate isolate;
  final SendPort isolatePort;

  _TtsManager({
    required this.receivePort,
    required this.isolate,
    required this.isolatePort,
  });
}

class IsolateTts {
  static late final _TtsManager _ttsManager;
  static SendPort get _sendPort => _ttsManager.isolatePort;
  static late StreamController<String>? _textQueue;
  static late bool _isProcessingQueue;
  static late ReceivePort mainReceivePort;
  static late bool interrupted;
  static late String currentOperationId;
  static late FlutterSoundPlayer _flutterSoundPlayer;
  static bool _playerIsInited = false;

  static Future<void> initAudioSessionForMusic() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  static Future<void> init() async {
    interrupted = false;
    currentOperationId = '';

    _flutterSoundPlayer = FlutterSoundPlayer();

    await initAudioSessionForMusic();
    if (Platform.isAndroid) {
      await _flutterSoundPlayer.openPlayer(isBGService: true);
    } else {
      await _flutterSoundPlayer.openPlayer();
    }

    _playerIsInited = true;

    mainReceivePort = ReceivePort();

    ReceivePort port = ReceivePort();
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;

    Isolate isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolateTask(port.sendPort, rootIsolateToken),
      errorsAreFatal: false,
    );

    port.listen((msg) async {
      if (msg is SendPort) {
        _ttsManager = _TtsManager(receivePort: port, isolate: isolate, isolatePort: msg);
        return;
      } else if (msg is _PortModel) {
        switch (msg.method) {
          case 'playAudio':
            try {
              final String filename = msg.data['filename'];
              if (_playerIsInited) {
                await _flutterSoundPlayer.startPlayer(
                    fromURI: filename,
                    whenFinished: () {
                      debugPrint('Finished playing audio');
                    }
                );
              }
            } catch (e) {
              debugPrint('Error playing audio in main isolate: $e');
            }
            break;
          case 'playBuffer':
            try {
              if (_playerIsInited) {
                final Float32List samples = msg.data['samples'];
                final int sampleRate = msg.data['sampleRate'];

                if (_flutterSoundPlayer.isPlaying) {
                  await _flutterSoundPlayer.stopPlayer();
                }

                final buffer = _float32ListToInt16PCM(samples);

                await initAudioSessionForMusic();
                await _flutterSoundPlayer.startPlayer(
                  fromDataBuffer: buffer,
                  codec: Codec.pcm16,
                  sampleRate: sampleRate,
                  numChannels: 1,
                  whenFinished: () {
                    debugPrint('Finished playing audio');
                  },
                );
              }
            } catch (e) {
              debugPrint('Error playing from buffer: $e');
            }
            break;
          case 'stopAudio':
            if (_playerIsInited && _flutterSoundPlayer.isPlaying) {
              await _flutterSoundPlayer.stopPlayer();
            }
            break;
        }
      }
    });
  }
  static Future<void> _isolateEntry(_IsolateTask task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }

    _isProcessingQueue = false;
    _textQueue = StreamController<String>();
    sherpa_onnx.initBindings();
    final receivePort = ReceivePort();
    task.sendPort.send(receivePort.sendPort);

    String modelDir = '';
    String modelName = '';
    String voices = ''; // for Kokoro only
    String ruleFsts = '';
    String ruleFars = '';
    String lexicon = '';
    String dataDir = '';
    String dictDir = '';

    modelDir = 'vits-piper-en_US-hfc_female-medium';
    modelName = 'en_US-hfc_female-medium.onnx';
    dataDir = 'vits-piper-en_US-hfc_female-medium/espeak-ng-data';

    if (modelName == '') {
      throw Exception(
          'You are supposed to select a model by changing the code before you run the app');
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    modelName = p.join(directory.path, modelDir, modelName);

    if (ruleFsts != '') {
      final all = ruleFsts.split(',');
      var tmp = <String>[];
      for (final f in all) {
        tmp.add(p.join(directory.path, f));
      }
      ruleFsts = tmp.join(',');
    }

    if (ruleFars != '') {
      final all = ruleFars.split(',');
      var tmp = <String>[];
      for (final f in all) {
        tmp.add(p.join(directory.path, f));
      }
      ruleFars = tmp.join(',');
    }

    if (lexicon.contains(',')) {
      final all = lexicon.split(',');
      var tmp = <String>[];
      for (final f in all) {
        tmp.add(p.join(directory.path, f));
      }
      lexicon = tmp.join(',');
    } else if (lexicon != '') {
      lexicon = p.join(directory.path, modelDir, lexicon);
    }

    if (dataDir != '') {
      dataDir = p.join(directory.path, dataDir);
    }

    if (dictDir != '') {
      dictDir = p.join(directory.path, dictDir);
    }

    final tokens = p.join(directory.path, modelDir, 'tokens.txt');
    if (voices != '') {
      voices = p.join(directory.path, modelDir, voices);
    }

    late final sherpa_onnx.OfflineTtsVitsModelConfig vits;
    late final sherpa_onnx.OfflineTtsKokoroModelConfig kokoro;

    if (voices != '') {
      vits = sherpa_onnx.OfflineTtsVitsModelConfig();
      kokoro = sherpa_onnx.OfflineTtsKokoroModelConfig(
        model: modelName,
        voices: voices,
        tokens: tokens,
        dataDir: dataDir,
        dictDir: dictDir,
        lexicon: lexicon,
      );
    } else {
      vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: modelName,
        lexicon: lexicon,
        tokens: tokens,
        dataDir: dataDir,
        dictDir: dictDir,
      );

      kokoro = sherpa_onnx.OfflineTtsKokoroModelConfig();
    }

    final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
      vits: vits,
      kokoro: kokoro,
      numThreads: 2,
      debug: true,
      provider: 'cpu',
    );

    final config = sherpa_onnx.OfflineTtsConfig(
      model: modelConfig,
      ruleFsts: ruleFsts,
      ruleFars: ruleFars,
      maxNumSenetences: 1,
    );

    late sherpa_onnx.OfflineTts _tts;

    receivePort.listen((msg) async {
      debugPrint('MSG: ${msg.method}-${msg.data}');
      if (msg is _PortModel) {
        switch (msg.method) {
          case 'speak':
            {
              _PortModel _v = msg;
              _textQueue?.add(_v.data['text']);
              if (!_isProcessingQueue) {
                _isProcessingQueue = true;
                await for (final text in _textQueue!.stream) {
                  if (_textQueue?.isClosed == true) {
                    // Stop processing if the stream is closed
                    break;
                  }
                  try {
                    final audio = _tts.generate(text: text, sid: 0, speed: 1.0);
                    debugPrint('Send to main isolate: $text');
                    final filename = await _generateWaveFilename();
                    final ok = sherpa_onnx.writeWave(
                      filename: filename,
                      samples: audio.samples,
                      sampleRate: audio.sampleRate,
                    );

                    if (ok) {
                      task.sendPort.send(_PortModel(
                        method: 'playBuffer',
                        data: {'samples': audio.samples, 'sampleRate': audio.sampleRate,},
                        sendPort: receivePort.sendPort,
                      ));

                      final durationMs = (audio.samples.length / audio.sampleRate * 1000).round() + 300;
                      await Future.delayed(Duration(milliseconds: durationMs));
                    }
                  } catch (e) {
                    debugPrint('error: $e');
                  }
                }
                _isProcessingQueue = false;
              }
            }
            break;
          case 'interrupt':
            {
              _textQueue?.close();
              task.sendPort.send(_PortModel(
                method: 'stopAudio',
                data: {},
                sendPort: receivePort.sendPort,
              ));
            }
            break;
          case 'restart':
            {
              _textQueue = StreamController<String>();
            }
            break;
        }
      }
    });
    _tts = sherpa_onnx.OfflineTts(config);
  }

  static Uint8List _float32ListToInt16PCM(Float32List float32List) {
    final pcmData = Uint8List(float32List.length * 2);
    final pcmBuffer = ByteData.view(pcmData.buffer);

    for (int i = 0; i < float32List.length; i++) {
      final sample = (float32List[i] * 32767).clamp(-32768, 32767).toInt();
      pcmBuffer.setInt16(i * 2, sample, Endian.little);
    }

    return pcmData;
  }

  static Future<String> _generateWaveFilename() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final filename = 'tmp.wav';
    return p.join(directory.path, filename);
  }

  static Future<void> speak({required String text, double speed = 1.0, required String operationId}) async {
    if (interrupted && operationId == currentOperationId) {
      return;
    } else if (interrupted && operationId != currentOperationId) {
      interrupted = false;
      currentOperationId = operationId;
      _sendPort.send(_PortModel(
        method: 'restart',
        data: {},
        sendPort: mainReceivePort.sendPort,
      ));
      _sendPort.send(_PortModel(
        method: 'speak',
        data: {'text': text, 'speed': speed},
        sendPort: mainReceivePort.sendPort,
      ));
    } else if (!interrupted) {
      _sendPort.send(_PortModel(
        method: 'speak',
        data: {'text': text, 'speed': speed},
        sendPort: mainReceivePort.sendPort,
      ));
    }
  }

  static Future<void> interrupt() async {
    interrupted = true;
    _sendPort.send(_PortModel(
      method: 'interrupt',
      data: {},
      sendPort: mainReceivePort.sendPort,
    ));
  }

  static Future<void> dispose() async {
    // await _audioPlayer?.dispose();
    await _flutterSoundPlayer.closePlayer();
  }
}

Future<List<String>> getTTSAssetFiles() async {
  final AssetManifest assetManifest =
  await AssetManifest.loadFromAssetBundle(rootBundle);
  final List<String> assets = assetManifest.listAssets();
  List<String> rets = [];
  for (final asset in assets) {
    if (asset.startsWith('assets/vits-piper-en_US-hfc_female-medium/espeak-ng-data')
        || asset == 'assets/vits-piper-en_US-hfc_female-medium/en_US-hfc_female-medium.onnx'
        || asset == 'assets/vits-piper-en_US-hfc_female-medium/en_US-hfc_female-medium.onnx.json'
        || asset == 'assets/vits-piper-en_US-hfc_female-medium/tokens.txt'
        || asset == 'assets/vits-piper-en_US-hfc_female-medium/MODEL_CARD') {
      rets.add(asset);
    }
  }
  return rets;
}

String stripLeadingDirectory(String src, {int n = 1}) {
  return p.joinAll(p.split(src).sublist(n));
}

Future<void> copyTTSAssetFiles() async {
  final allFiles = await getTTSAssetFiles();
  for (final src in allFiles) {
    final dst = stripLeadingDirectory(src);
    await copyTTSAssetFile(src, dst);
  }
}

// Copy the asset file from src to dst.
// If dst already exists, then just skip the copy
Future<String> copyTTSAssetFile(String src, [String? dst]) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  if (dst == null) {
    dst = p.basename(src);
  }
  final target = p.join(directory.path, dst);
  bool exists = await new File(target).exists();

  final data = await rootBundle.load(src);
  if (!exists || File(target).lengthSync() != data.lengthInBytes) {
    final List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await (await File(target).create(recursive: true)).writeAsBytes(bytes);
  }

  return target;
}