import asyncio
import websockets

async def test_connection():
    try:
        async with websockets.connect("ws://localhost:8080") as ws:
            print("✅ Server accessible locally")
    except Exception as e:
        print(f"❌ Local connection failed: {e}")

    try:
        async with websockets.connect("ws://10.0.2.2:8080") as ws:
            print("✅ Emulator alias accessible")
    except Exception as e:
        print(f"❌ 10.0.2.2 connection failed: {e}")

asyncio.run(test_connection())