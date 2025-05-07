import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'objectbox_service.dart';

class Embeddings {

  final String apiKey ;
  final String baseUrl;

  static const String defaultBaseUrl = 'https://one-api.bud.inc/v1/embeddings';

  // Private constructor for calling the create factory method
  Embeddings._(this.apiKey, this.baseUrl);

  static Future<Embeddings> create() async {
    final config = ObjectBoxService().getConfigsByModel("embeddings");
    if (config != null && config.apiKey != null && config.baseUrl != null) {
      return Embeddings._(config.apiKey!, config.baseUrl!);
    } else {
      final token = await FlutterForegroundTask.getData(key: 'llmToken');
      return Embeddings._(token, defaultBaseUrl);
    }
  }

  Future<List<double>?> getEmbeddings(String text) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "input": text,
        "model": "text-embedding-3-small",
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final embeddings = responseData['data'][0]['embedding'] as List;
      return embeddings.map((e) => (e as num).toDouble()).toList();
    } else {
      throw Exception("Failed to load embeddings");
    }
  }

  Future<List<List<double>>?> getMultipleEmbeddings(List<String> texts) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "input": texts,
        "model": "text-embedding-3-small",
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final embeddings = List<List<double>>.from(responseData['data'].map((item) => List<double>.from(item['embedding'])));
      return embeddings;
    } else {
      throw Exception("Failed to load embeddings");
    }
  }
}
