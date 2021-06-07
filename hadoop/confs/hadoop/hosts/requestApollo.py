#/usr/bin/python
#encoding=utf-8

import requests
import json
import pdb
import sys
reload(sys)
sys.setdefaultencoding( "utf-8" )


class RequestApollo:

    def __init__(self):
        url = "http://58.215.174.180:8080/configfiles/json/hadoop-conf/default/INF.etc?"
        self.request = requests.get(url, timeout=10)

    def getDict(self):        
        if (200 == self.request.status_code):
            return json.loads(self.request.content)
        return null
    def __del__(self):
        self.request.close()

requestApollo = RequestApollo()
confDict = requestApollo.getDict()
if (len(confDict) != 1):
    print "request conf fail"

fp = open("hosts", 'w+')
fp.write(confDict['hosts'])

