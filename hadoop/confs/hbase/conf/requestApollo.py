#/usr/bin/python

import requests
import json
from  operateFile import OperateFile
import pdb

url="http://58.215.174.180:8080/configfiles/json/hbase-conf/default/application?"


class RequestApollo:

    def __init__(self, url):
        self.request = requests.get(url)
        if (200 == self.request.status_code):
            self.dealRequest()

    def dealRequest(self):
        requestDict = json.loads(self.request.content)
        operateFile = OperateFile()
        operateFile.write(requestDict)
        

if __name__ == '__main__':
    requestApollo = RequestApollo(url)
