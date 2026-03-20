from http.server import HTTPServer, BaseHTTPRequestHandler
import json

CACHE = {}
counter = 0

class LeakyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global counter
        counter += 1
        # BUG: keys are never cleaned up
        CACHE[f"request_{counter}"] = "X" * 10240  # 10KB per request
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        response = {"cache_size": len(CACHE), "counter": counter}
        self.wfile.write(json.dumps(response).encode())

HTTPServer(("", 8080), LeakyHandler).serve_forever()
