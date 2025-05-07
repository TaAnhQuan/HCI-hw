import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import '../constants/prompt_constants.dart';
import '../models/llm_config.dart';
import 'objectbox_service.dart';


class LLM {
  String modelName;
  late String apiKey;
  late String baseUrl;
  late String systemPrompt;

  static final String defaultBaseUrl = 'https://one-api.bud.inc/v1/chat/completions';

  LLM._(this.modelName, this.apiKey, this.baseUrl, this.systemPrompt);

  static Future<LLM> create(String modelName, {String? systemPrompt}) async {
    final prompt = systemPrompt ?? systemPromptOfChat;

    LlmConfigEntity? config = ObjectBoxService().getConfigsByModel(modelName);

    if (config != null && config.apiKey != null && config.baseUrl != null) {
      return LLM._(modelName, config.apiKey!, config.baseUrl!, prompt);
    } else {
      final token = await FlutterForegroundTask.getData(key: 'llmToken');
      return LLM._(modelName, token, defaultBaseUrl, prompt);
    }
  }

  // Sends a request to the LLM with user input
  Future<String> createRequest({required String content}) async {
    final url = Uri.parse(baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Prepare the request body
    final body = jsonEncode({
      'model': modelName,
      'messages': [{"role": "system", "content": systemPrompt}, {"role": "user", "content": content}],
    });

    final response = await http.post(url, headers: headers, body: body);
    return _handleResponse(response);
  }

  // Handles non-streamed responses
  String _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes))['choices'][0]['message'];
      try {
        return data['content'];
      } catch (e) {
        throw Exception('Json decode failed.');
      }
    } else {
      throw Exception('Failed to fetch response from LLM');
    }
  }

  Stream<String> createStreamingRequest({
    String? content,
    List<Map<String, String>>? messages,
    Object? jsonSchema,
    int retryCount = 3,
  }) async* {
    for (int i = 0; i < retryCount; i++) {
      try {
        final url = Uri.parse(baseUrl);
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

        if (messages != null && messages.isNotEmpty) {
          if (messages[0]["role"] != "system") {
            messages.insert(0, {"role": "system", "content": systemPrompt});
          }
        } else {
          messages = [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": content!}
          ];
        }

        final Map<String, Object> responseFormat = {'type': 'json_object'};
        if (jsonSchema != null) {
          responseFormat['json_schema'] = jsonSchema;
        }

        final body = jsonEncode({
          'model': modelName,
          'messages': messages,
          'stream': true,
          'response_format': responseFormat,
        });

        yield* _handleStreamingResponse(url, headers, body);
        break;
      } catch (e) {
        if (i == retryCount - 1) rethrow;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  // Handles streamed responses
  Stream<String> _handleStreamingResponse(Uri url, Map<String, String> headers, String body) async* {
    final request = http.Request('POST', url);
    request.headers.addAll(headers);
    request.body = body;

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch streaming response from LLM');
    }

    // Logic for processing streamed response content
    final responseStream = response.stream.transform(utf8.decoder);
    StringBuffer buffer = StringBuffer();

    // Process incoming chunks of data
    await for (var chunk in responseStream) {
      try {
        List<String> jsonParts = chunk.toString().split('\n');

        for (String part in jsonParts) {
          if (part.length > 6 && part != "data:[DONE]") {
            // Attempt to parse each JSON string
            try {
              var content = jsonDecode(part.substring(5))["choices"][0]["delta"]["content"];
              if (content != null) {
                buffer.write(content);
                yield buffer.toString();
              }
            } catch (e) {
              // JSON string is incomplete, continue accumulating
              continue;
            }
          }
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void setSystemPrompt({required String systemPrompt}) {
    this.systemPrompt = systemPrompt;
  }
}
