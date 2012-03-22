#!/user/bin/env python
import json
from socket import socket
import time

from twisted.web import server, resource
from twisted.internet import reactor

CARBON_PORT=2003
CARBON_HOST='127.0.0.1'

# Test with:
# curl 127.0.0.1:8080 -XPOST -d "{\"proxied2\":{\"there\":\"100\", \"and\": {\"here\": \"$RANDOM\"}}}"

class GraphiteProxy(resource.Resource):
    isLeaf = True
    def render_GET(self, request):
        return "GraphiteProxy"

    def render_POST(self, request):
        """Takes a json object, flattens it, and sends data to graphite."""

        raw_value = request.content.read()
        value = json.loads(raw_value)
        metrics = self._flatten(value)
        self._send(metrics)

        ret = ""
        for k,v in metrics.items():
            ret += "%s %s\n" % (k,v)
        return str(ret)

    def _send(self, metrics):
        """
        Converts the key/value metrics dict into a Carbon formatted message
        and sends to carbon over a socket.
        """
        sock = socket()
        sock.connect( (CARBON_HOST,CARBON_PORT) )

        now = int( time.time() )
        lines = []
        for k,v in metrics.items():
            lines.append("%s %s %d" % (k,v, now))
        message = '\n'.join(lines) + '\n' #all lines must end in a newline
        print "sending message\n"
        print '-' * 80
        print message
        print
        sock.sendall(message)
        sock.close()

    def _flatten(self, value, parent=""):
        """Flattens a json object's keys"""
        if type(value) is dict:
            result = {}
            for k,v in value.items():
                if parent:
                    level = "%s.%s" % (parent, k)
                else:
                    level = k

                result.update(self._flatten(v, level))
            return result
        else:
            return {parent: value}


site = server.Site(GraphiteProxy())
reactor.listenTCP(8080, site)
reactor.run()
