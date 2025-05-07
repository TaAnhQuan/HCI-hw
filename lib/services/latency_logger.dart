import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LatencyLogger {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  static final Uuid _uuid = Uuid();

  // {operationId: {'start': t0, 'llm': t1, 'tts': t2}}
  static final _timestamps = <String, Map<String, dynamic>>{};

  static String recordStart() {
    final operationId = _uuid.v4();
    _timestamps[operationId] = {
      'start': DateTime.now(),
      'llm': null,
      'tts': null,
      'llmLogged': false,
      'ttsLogged': false,
    };
    return operationId;
  }

  static void recordEnd(String operationId, {required String phase}) async {
    final timestamps = _timestamps[operationId];
    if (timestamps == null || timestamps[phase] != null) return;

    timestamps[phase] = DateTime.now();

    _checkAndLog(operationId);
  }

  static void _checkAndLog(String operationId) async {
    try {
      final data = _timestamps[operationId];
      if (data == null) return;

      final start = data['start'] as DateTime;
      final llmEnd = data['llm'] as DateTime?;
      final ttsEnd = data['tts'] as DateTime?;

      if (llmEnd != null && !data['llmLogged']) {
        final llmLatency = llmEnd.difference(start).inMilliseconds;
        await _writeToFile('Operation ID: $operationId | LLM   Latency: ${llmLatency}ms | Status: SUCCESS');
        data['llmLogged'] = true;
      }

      if (ttsEnd != null && !data['ttsLogged']) {
        final totalLatency = ttsEnd.difference(start).inMilliseconds;
        final ttsLatency = totalLatency - (llmEnd?.difference(start).inMilliseconds ?? 0);

        await _writeToFile('Operation ID: $operationId | TTS   Latency: ${ttsLatency}ms | Status: SUCCESS');
        await _writeToFile('Operation ID: $operationId | TOTAL Latency: ${totalLatency}ms | Status: SUCCESS\n');
        data['ttsLogged'] = true;

        _timestamps.remove(operationId);
      }
    } catch (e) {
      await _writeToFile("Operation ID: $operationId | Message: $e | Status: ERROR");
    }

  }

  static Future<void> _writeToFile(String line) async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/latency_report.txt');

    unawaited(logFile.writeAsString('${_dateFormatter.format(DateTime.now())}, $line\n',
        mode: FileMode.append));
  }
}