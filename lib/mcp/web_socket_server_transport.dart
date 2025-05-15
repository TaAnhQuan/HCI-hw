import 'dart:async';
import 'dart:io';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketServerTransport {
  final int port;
  HttpServer? _server;
  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>();

  WebSocketServerTransport({required this.port});

  Future<void> initialize() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.transform(WebSocketTransformer()).listen(_handleWebSocket);
  }

  void _handleWebSocket(WebSocket webSocket) {
    _channel = IOWebSocketChannel(webSocket);
    _channel!.stream.listen(
          (data) => _controller.add(data),
      onError: (error) => _controller.addError(error),
      onDone: () => _controller.close(),
    );
  }

  Stream<dynamic> get stream => _controller.stream;

  void send(dynamic message) {
    _channel?.sink.add(message);
  }

  Future<void> close() async {
    await _channel?.sink.close();
    await _server?.close();
    await _controller.close();
  }
}