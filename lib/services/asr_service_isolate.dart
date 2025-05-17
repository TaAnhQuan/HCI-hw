import 'dart:isolate';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import '../utils/asr_utils.dart';

class AsrServiceIsolate{
  late SendPort sendPort;
  late Isolate _isolate;
  bool isInitialized = false;
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

  Future init()async{
    var receivePort = ReceivePort();
    await getNonstreamingModelConfig();
    _isolate = await Isolate.spawn(_handle, receivePort.sendPort);
    sendPort = await receivePort.first;
    receivePort.close();
    final task = Task("init", "");
    sendPort.send(task.toList());
    await task.response.first;
    isInitialized = true;
  }

  _handle(SendPort sendPort)async{
    sherpa_onnx.OfflineRecognizer? _nonstreamRecognizer;
    var receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var msg in receivePort) {
      if (msg is List<Object>) {
        final action = msg[0] as String;
        final sendPort = msg[2] as SendPort;
        if (action == 'init') {
          sherpa_onnx.initBindings();
          BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
          _nonstreamRecognizer ??= await createNonstreamingRecognizer();
          sendPort.send("initialized");
        } else if(action =='stopRecord')
        {
          _nonstreamRecognizer?.free();
          sendPort.send("stopped");
        } else if(action =='sendData')
        {
          final samples = msg[1] as dynamic;
          final nonstreamStream = _nonstreamRecognizer!.createStream();
          nonstreamStream.acceptWaveform(samples: samples, sampleRate: 16000);
          _nonstreamRecognizer.decode(nonstreamStream);
          sendPort.send( _nonstreamRecognizer.getResult(nonstreamStream).text);
          nonstreamStream.free();
        }
      }
    }
  }

  Future<String> sendData(Float32List data) async {
    final task = Task("sendData", data);
    sendPort.send(task.toList());
    final result= await task.response.first;
    return result;
  }

  Future stopRecord() async {
    final task = Task("stopRecord", "");
    sendPort.send(task.toList());
    await task.response.first;
  }
}

class Task{
  final String action;
  final dynamic data;
  final ReceivePort  response = ReceivePort();
  Task(this.action, this.data);

  List<Object> toList()=>[action,data,response.sendPort];
}

Future<sherpa_onnx.OfflineRecognizer> createNonstreamingRecognizer() async {
  final modelConfig = await getNonstreamingModelConfig();
  final config = sherpa_onnx.OfflineRecognizerConfig(
    model: modelConfig,
    ruleFsts: '',
  );

  return sherpa_onnx.OfflineRecognizer(config);
}

Future<sherpa_onnx.OfflineModelConfig> getNonstreamingModelConfig() async {
  const modelDir = 'assets/sherpa-onnx-whisper-tiny.en';
  return sherpa_onnx.OfflineModelConfig(
    whisper: sherpa_onnx.OfflineWhisperModelConfig(
        encoder: await copyAssetFile('$modelDir/tiny.en-encoder.int8.onnx'),
        decoder: await copyAssetFile('$modelDir/tiny.en-decoder.int8.onnx'),
        tailPaddings: 1000
    ),
    tokens: await copyAssetFile('$modelDir/tiny.en-tokens.txt'),
  );
}