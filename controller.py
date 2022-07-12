from http.server import BaseHTTPRequestHandler, HTTPServer
from os import environ, kill
import json
import shlex
import signal
import subprocess
import uuid

controller_port = int(environ.get('CONTROLLER_PORT', 9000))
screen_width = int(environ.get('SCREEN_WIDTH', 1360))
screen_height = int(environ.get('SCREEN_HEIGHT', 1020))
frame_rate = int(environ.get('FRAME_RATE', 15))
codec = environ.get('CODEC', 'libx264')
preset = environ.get('PRESET', '-preset ultrafast')
video_size=f'{screen_width}x{screen_height}'

pids = {}

class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/start':
            self.do_start()
        elif self.path == '/stop':
            self.do_stop()

    def get_data(self):
        data_string = self.rfile.read(int(self.headers['Content-Length']))
        return json.loads(data_string)

    def do_start(self):
        data = self.get_data()
        self.send_response(200)
        self.end_headers()

        host = data['host']
        display = data['display']
        file_name = data['file_name']

        video_id = str(uuid.uuid4())
        command = shlex.split(f'ffmpeg -y -f x11grab -video_size {video_size} -r {frame_rate} -i {host}:{display}.0 -codec:v {codec} {preset} -pix_fmt yuv420p "/videos/{file_name}"')
        proc = subprocess.Popen(command, close_fds=True)
        pids[video_id] = proc.pid

        self.wfile.write(json.dumps({'video_id': video_id}).encode('utf-8'))

    def do_stop(self):
        data = self.get_data()
        self.send_response(200)
        self.end_headers()

        video_id = data['video_id']
        pid = pids[video_id]
        kill(pid, signal.SIGINT)
        del pids[video_id]

        self.wfile.write(json.dumps({'pid': pid}).encode('utf-8'))

httpd = HTTPServer(('', controller_port), RequestHandler)

httpd.serve_forever()
