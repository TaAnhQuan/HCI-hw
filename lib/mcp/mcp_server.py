import asyncio
import json
import aiohttp
from websockets import serve

# Base URLs for Open‑Meteo services
GEOCODING_API = "https://geocoding-api.open-meteo.com/v1/search"
FORECAST_API = "https://api.open-meteo.com/v1/forecast"

USER_AGENT = "weather-app/1.0 (Python)"

async def make_http_request(url: str, params: dict = None) -> dict | None:
    """
    Perform a GET request to 'url' with optional query parameters.
    Return JSON on success (HTTP 200) or None on error.
    """
    headers = {
        "User-Agent": USER_AGENT,
        "Accept": "application/json"
    }
    try:
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.get(url, params=params) as response:
                if response.status != 200:
                    # Uncomment to debug:
                    # print(f"HTTP {response.status} for {response.url}")
                    return None
                return await response.json()
    except Exception as e:
        print(f"Error making HTTP request to {url}: {e}")
        return None

class McpServer:
    def __init__(self):
        self.tools: dict[str, dict] = {}
        self.pending_requests: dict = {}

    def tool(self, name: str, description: str, input_schema: dict, callback):
        self.tools[name] = {
            "description": description,
            "input_schema": input_schema,
            "callback": callback
        }

    async def handle_connection(self, websocket):
        print(f"New connection from {websocket.remote_address}")
        async for message in websocket:
            try:
                print(f"Received: {message}")
                data = json.loads(message)
                request_id = data.get("id")
                method = data.get("method")
                params = data.get("params", {})

                if method in self.tools:
                    result = await self.tools[method]["callback"](params)
                    response = {
                        "jsonrpc": "2.0",
                        "id": request_id,
                        "result": {
                            "content": [{"text": result}]
                        }
                    }
                else:
                    response = {
                        "jsonrpc": "2.0",
                        "id": request_id,
                        "error": {
                            "code": -32601,
                            "message": f"Method '{method}' not found"
                        }
                    }

                print(f"Sending: {json.dumps(response)}")
                await websocket.send(json.dumps(response))
            except Exception as e:
                print(f"Error handling request: {e}")

async def get_alerts(params):
    """
    Open-Meteo does not provide a free worldwide alerts feed.
    Return a stub message.
    """
    return "Weather alerts are not supported via Open-Meteo."

async def geocode_city(city: str) -> tuple[float, float] | None:
    """
    Use Open‑Meteo’s geocoding endpoint to look up a city name.
    Returns (latitude, longitude) of the first match, or None if not found.
    """
    if not city:
        return None

    params = {
        "name": city,
        "count": 1,       # only need the top match
        "language": "en"
    }
    data = await make_http_request(GEOCODING_API, params=params)
    if data and "results" in data and len(data["results"]) > 0:
        top = data["results"][0]
        return (top["latitude"], top["longitude"])
    return None

async def get_forecast(params):
    """
    Fetch current weather + a short daily forecast using Open‑Meteo.
    Accepts:
      - {"city": "Berlin"}           → geocode, then forecast
      - {"latitude": 48.1351, "longitude": 11.5820}
    Returns a formatted multi-line string.
    """
    # 1) Check for city name or lat/lon
    latitude = params.get("latitude")
    longitude = params.get("longitude")
    city = params.get("city")

    if city and (latitude is None or longitude is None):
        coords = await geocode_city(city)
        if not coords:
            return f"Could not find coordinates for city: {city}"
        latitude, longitude = coords

    if latitude is None or longitude is None:
        return "Please specify either a city name or both latitude and longitude."

    # 2) Call Open-Meteo’s forecast endpoint:
    #    - current_weather=true gives the current temperature, windspeed, etc.
    #    - daily=temperature_2m_max,temperature_2m_min gives tomorrow’s highs/lows
    #    - timezone=auto returns times in the location’s timezone.
    params_owm = {
        "latitude": float(latitude),
        "longitude": float(longitude),
        "current_weather": "true",  # <-- convert to string
        "daily": "temperature_2m_max,temperature_2m_min",
        "timezone": "auto"
    }
    data = await make_http_request(FORECAST_API, params=params_owm)
    if not data:
        return f"Failed to retrieve weather data for {city or f'{latitude},{longitude}'}."

    # 3) Parse and format the response
    try:
        # Current weather block
        cw = data.get("current_weather", {})
        temp = cw.get("temperature")
        windspeed = cw.get("windspeed")
        winddirection = cw.get("winddirection")
        weather_time = cw.get("time")  # ISO time

        # Daily forecast block: get today’s index (0) and tomorrow’s (1)
        daily = data.get("daily", {})
        dates = daily.get("time", [])
        temp_max = daily.get("temperature_2m_max", [])
        temp_min = daily.get("temperature_2m_min", [])

        # Build lines
        lines = []
        location_name = f"{city}" if city else f"{latitude:.4f}, {longitude:.4f}"
        lines.append(f"Location: {location_name}")
        lines.append(f"Current (as of {weather_time}):")
        lines.append(f"  • Temperature: {temp}°C")
        lines.append(f"  • Wind: {windspeed} m/s (direction {winddirection}°)")
        lines.append("Daily Forecast:")

        # If have daily arrays, show day 0 and day 1
        if len(dates) >= 1:
            lines.append(f"  {dates[0]}  → High {temp_max[0]}°C, Low {temp_min[0]}°C")
        if len(dates) >= 2:
            lines.append(f"  {dates[1]}  → High {temp_max[1]}°C, Low {temp_min[1]}°C")

        return "\n".join(lines)
    except Exception as e:
        print(f"Error parsing Open-Meteo response: {e}")
        return "Unexpected response format from Open-Meteo."

async def get_coordinates_for_city(city):
    city_coordinates = {
        "new york": (40.7128, -74.0060),
        "los angeles": (34.0522, -118.2437),
        "chicago": (41.8781, -87.6298),
        "houston": (29.7604, -95.3698),
    }
    return city_coordinates.get(city.strip().lower())


async def main():
    server = McpServer()

    server.tool(
        name="get-alerts",
        description="(stub) Alerts not available via Open-Meteo free API",
        input_schema={"state": {"type": "string", "description": "unused"}},
        callback=get_alerts
    )

    server.tool(
        name="get-forecast",
        description="Get current weather + short daily forecast (worldwide)",
        input_schema={
            "city": {"type": "string", "description": "City name (optional)"},
            "latitude": {"type": "number", "description": "Latitude (optional)"},
            "longitude": {"type": "number", "description": "Longitude (optional)"}
        },
        callback=get_forecast
    )

    async with serve(server.handle_connection, "0.0.0.0", 8080):
        print("Weather MCP (Open‑Meteo) running on ws://0.0.0.0:8080")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
