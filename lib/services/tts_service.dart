// Copyright (c)  2024  Xiaomi Corporation

import "dart:io";

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import 'package:sherpa_onnx/sherpa_onnx.dart';

import '../utils/tts_utils.dart';

class TtsService {
  sherpa_onnx.OfflineTts? _tts;

  Future<void> initialize() async {
    _tts?.free();
    _tts = await createOfflineTts();
  }

  GeneratedAudio speak(String text) {
    if (_tts == null) {
      throw Exception('TTS is not initialized');
    }

    final audio = _tts!.generate(text: text, sid: 0, speed: 1.0);
    return audio;
  }

  void dispose() {
    _tts?.free();
  }
}

Future<sherpa_onnx.OfflineTts> createOfflineTts() async {
  // sherpa_onnx requires that model files are in the local disk, so we
  // need to copy all asset files to disk.
  await copyAllAssetFiles();

  sherpa_onnx.initBindings();

  // Such a design is to make it easier to build flutter APPs with
  // github actions for a variety of tts models
  //
  // See https://github.com/k2-fsa/sherpa-onnx/blob/master/scripts/flutter/generate-tts.py
  // for details

  String modelDir = 'sherpa-onnx-vits-zh-ll';
  String modelName = 'model.onnx';
  String ruleFsts = '';
  String ruleFars = '';
  String lexicon = 'lexicon.txt';
  String dataDir = '';
  String dictDir = 'sherpa-onnx-vits-zh-ll/dict';

  // ============================================================
  // Please don't change the remaining part of this function
  // ============================================================
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

  if (lexicon != '') {
    lexicon = p.join(directory.path, modelDir, lexicon);
  }

  if (dataDir != '') {
    dataDir = p.join(directory.path, dataDir);
  }

  if (dictDir != '') {
    dictDir = p.join(directory.path, dictDir);
  }

  final tokens = p.join(directory.path, modelDir, 'tokens.txt');

  final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
    model: modelName,
    lexicon: lexicon,
    tokens: tokens,
    dataDir: dataDir,
    dictDir: dictDir,
  );

  final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
    vits: vits,
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
  // print(config);

  final tts = sherpa_onnx.OfflineTts(config);

  return tts;
}
