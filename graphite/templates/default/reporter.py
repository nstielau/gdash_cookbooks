#!/usr/bin/env python

import httplib
import json
import os
import re


HOST="127.0.0.1"
PORT="10001"
BINDING_ID="5cecf7e9fe224d4bbc255c14dc6aafc0"
ACCESS_KEY="63e0d523c1434bffbb375d84bfae8331"

web_server = httplib.HTTPConnection(HOST, PORT, timeout=2)
web_server.request("GET", '/nginx_status', '', {"X-Access-Key": ACCESS_KEY})
try:
    result = web_server.getresponse()
except Exception as e:
    raise "Status request failed! Nginx might not be online yet so perhaps try running it again? %s" % e

nginx_status = result.read()
nginx_connection_stats = nginx_status.split('\n')[2].strip().split(' ')
metrics = {}
metrics['bindings'] = {}
metrics['bindings'][BINDING_ID] = {}
metrics['bindings'][BINDING_ID]['nginx_accepted_connections'] = nginx_connection_stats[0]
metrics['bindings'][BINDING_ID]['nginx_handled_connections'] = nginx_connection_stats[1]
metrics['bindings'][BINDING_ID]['nginx_handled_requests'] = nginx_connection_stats[2]

metrics['system'] = {}
metrics['system']['binding_count'] = len(os.listdir('/srv/bindings'))


print "Sending metrics to graphite: %s" % json.dumps(metrics)

web_server = httplib.HTTPConnection('50.57.137.165', '8080', timeout=2)
web_server.request("POST", '/', json.dumps(metrics))
