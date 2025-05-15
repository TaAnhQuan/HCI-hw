
import 'dart:convert';
import 'dart:io';

import 'package:app/mcp/web_socket_server_transport.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:mcp_dart/src/shared/transport.dart';

const String nwsApiBase = "https://api/weather.gov";
const String userAgent = "weather-app/1.0";

Future<Map<String, dynamic>?> makeNWSRequest(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, userAgent);
    request.headers.set(HttpHeaders.acceptHeader, "application/geo+json");

    final response = await request.close();
    if (response.statusCode != 200){
      throw HttpException(
        "HTTP error! status ${response.statusCode}",
        uri: Uri.parse(url),
      );
    }

    final responseBody = await response.transform(utf8.decoder).join();
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } catch (error){
    stderr.writeln("Error making NWS request: $error");
    return null;
  } finally {
    client.close();
  }
}

String formatAlert(Map<String, dynamic> feature){
  final props = feature['properties'] ?? {};

  return [
    "Evnet: ${props['event'] ?? 'Unkown'}",
    "Area: ${props['areaDesc'] ?? 'Unknown'}",
    "Severity: ${props['severity'] ?? 'Unknown'}",
    "Status: ${props['status'] ?? 'Unknown'}",
    "Headline: ${props['headline'] ?? 'No headline'}"
  ].join("\n");
}

void main() async {
  final server = McpServer(const Implementation(
    name: "weather", version: "1.0.0"
  ));

  server.tool(
      "get-alerts",
      description: "get weather alerts for a state",
      inputSchemaProperties: {
        "state": {
          "type": "string",
          "description": "Two-letter state code (e.g. CA, NY)",
        }
      },
      callback: ({args, extra}) async {
        final state = (args?['state'] as String?)?.toUpperCase();
        if (state == null || state.length != 2){
          return const CallToolResult(
              content: [TextContent(text: "Invalid state code provided")],
              isError: true,
          );
        }

        final alertsUrl = "$nwsApiBase/alerts?area=$state";
        final alertsData = await makeNWSRequest(alertsUrl);

        if (alertsData == null) {
          return const CallToolResult(
            content: [TextContent(text: "Failed to retrieve alerts data.")],
          );
        }

        final features = alertsData['features'] as List<dynamic>? ?? [];
        if (features.isEmpty) {
          return CallToolResult(
            content: [TextContent(text: "No active alerts for $state.")],
          );
        }

        final formattedAlerts =
        features.map((feature) => formatAlert(feature)).join("\n");
        final alertsText = "Active alerts for $state:\n\n$formattedAlerts";

        return CallToolResult(content: [TextContent(text: alertsText)]);
      }
  );

  server.tool(
    "get-forecast",
    description: "Get weather forecast for a location",
    inputSchemaProperties: {
      "latitude": {"type": "number", "description": "Latitude of the location"},
      "longitude": {
        "type": "number",
        "description": "Longitude of the location",
      },
    },
    callback: ({args, extra}) async {
      final latitude = args?['latitude'] as num?;
      final longitude = args?['longitude'] as num?;

      if (latitude == null || longitude == null) {
        return const CallToolResult(
          content: [TextContent(text: "Invalid latitude or longitude.")],
          isError: true,
        );
      }

      final pointsUrl =
          "$nwsApiBase/points/${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}";
      final pointsData = await makeNWSRequest(pointsUrl);

      if (pointsData == null) {
        return CallToolResult(
          content: [
            TextContent(
              text:
              "Failed to retrieve grid point data for coordinates: $latitude, $longitude. This location may not be supported by the NWS API (only US locations are supported).",
            ),
          ],
        );
      }

      final forecastUrl = pointsData['properties']?['forecast'] as String?;
      if (forecastUrl == null) {
        return const CallToolResult(
          content: [
            TextContent(
              text: "Failed to get forecast URL from grid point data.",
            ),
          ],
        );
      }

      final forecastData = await makeNWSRequest(forecastUrl);
      if (forecastData == null) {
        return const CallToolResult(
          content: [TextContent(text: "Failed to retrieve forecast data.")],
        );
      }

      final periods =
          forecastData['properties']?['periods'] as List<dynamic>? ?? [];
      if (periods.isEmpty) {
        return const CallToolResult(
          content: [TextContent(text: "No forecast periods available.")],
        );
      }

      final formattedForecast = periods.map((period) {
        final periodMap = period as Map<String, dynamic>;
        return [
          "${periodMap['name'] ?? 'Unknown'}:",
          "Temperature: ${periodMap['temperature'] ?? 'Unknown'}°${periodMap['temperatureUnit'] ?? 'F'}",
          "Wind: ${periodMap['windSpeed'] ?? 'Unknown'} ${periodMap['windDirection'] ?? ''}",
          "${periodMap['shortForecast'] ?? 'No forecast available'}",
          "---",
        ].join("\n");
      }).join("\n");

      final forecastText =
          "Forecast for $latitude, $longitude:\n\n$formattedForecast";

      return CallToolResult(content: [TextContent(text: forecastText)]);
    },
  );

  final transport = WebSocketServerTransport(port: 8080);
  await server.connect(transport as Transport);
  stderr.writeln("Weather MCP running on stdio");
}
