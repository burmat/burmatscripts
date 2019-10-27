from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'home base contacted')


httpd = HTTPServer(('10.1.1.123', 443), SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, 
        keyfile="key.pem", 
        certfile="cert.pem", server_side=True)

httpd.serve_forever()
