import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:app/models/mcp_models.dart';
import 'package:flutter/foundation.dart';
import 'package:mcp_dart/mcp_dart.dart';

class McpClient{
  final String serverId;
  final Client mcp;
  StdioClientTransport? _transport;
  List<McpToolDefinition> _tools = [];
  bool _isConnected = false;

  Function(String serverId, String errorMsg)? _onError;
  Function(String serverId, List<McpToolDefinition> tools)? _onConnectionSuccess;
  Function(String serverId)? _onClose;

  bool get isConnected => _isConnected;
  List<McpToolDefinition> get availableTools => List.unmodifiable(_tools);

  McpClient(this.serverId) : mcp = Client(
      const Implementation(
          name: "mcp-client",
          version: "1.0.0",
      )
  );

  void setupCallbacks({
    Function(String serverId, String errorMsg)? onError,
    Function(String serverId, List<McpToolDefinition> tools)? onConnectSuccess,
    Function(String serverId)? onClose,
  }){
    _onError = onError;
    _onConnectionSuccess = onConnectSuccess;
    _onClose = onClose;
  }

  Future<void> connectToServer(String command, List<String> args, Map<String, String> environment) async {
    if (_isConnected) return;
    if (command.trim().isEmpty){
      throw ArgumentError("MCP command cannot be empty");
    }
    debugPrint("McpClient [$serverId]: Connecting $command ${args.join(' ')}");

    final Function(String serverId)? localOnCloseCallback = _onClose;
    try{
      _transport = StdioClientTransport(
        StdioServerParameters(
          command: command,
          args: args,
          environment: environment,
          stderrMode: ProcessStartMode.normal,
        )
      );
      _transport!.onerror = (error){
        final errorMsg = "MCP Transport error [$serverId] : $error";
        debugPrint(errorMsg);
        _isConnected = false;
        _onError?.call(serverId, errorMsg);
      };
      _transport!.onclose = () {
        // This handler is primarily for *unexpected* closures
        debugPrint("MCP Transport closed unexpectedly [$serverId].");
        _isConnected = false;
        // Use the locally stored callback reference
        localOnCloseCallback?.call(serverId); // Notify manager
        _transport = null;
        _tools = []; // Clear tools on close
      };
      await mcp.connect(_transport!);
      _isConnected = true;
      debugPrint(
        "McpClient [$serverId]: Connected successfully. Fetching tools...",
      );
      await _fetchTools(); // Fetch tools immediately after connect
      _onConnectionSuccess?.call(
        serverId,
        _tools,
      );
    } catch (e) {
      debugPrint("McpClient [$serverId]: Failed to connect: $e");
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> _fetchTools() async {
    if (!_isConnected) {
      _tools = [];
      return;
    }
    debugPrint("McpClient [$serverId]: Fetching tools...");
    try {
      final toolsResult = await mcp.listTools();
      List<McpToolDefinition> fetchedTools = [];
      for (var toolDef in toolsResult.tools) {
        // Directly use the schema Map provided by mcp_dart
        final schemaMap = toolDef.inputSchema.toJson();

        // Basic validation: Ensure schema is a Map
        fetchedTools.add(
          McpToolDefinition(
            name: toolDef.name,
            description: toolDef.description,
            inputSchema: schemaMap, // Store the raw Map
          ),
        );
      }
      _tools = fetchedTools;
      debugPrint("McpClient [$serverId]: Discovered ${_tools.length} tools.");
    } catch (e) {
      debugPrint("McpClient [$serverId]: Failed to fetch MCP tools: $e");
      _tools = []; // Clear tools on error
      // Optionally notify via onError callback? Or let connect fail?
      // _onError?.call(serverId, "Failed to fetch tools: $e");
      rethrow; // Rethrow fetch error to potentially fail the connection process
    }
  }
}