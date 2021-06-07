#/usr/bin/python

import requests
import json
from config import apollo_conf
import pdb


class RequestApollo:

    def __init__(self):
        url = apollo_conf['url']
        self.request = requests.get(url)

    def getDict(self):        
        if (200 == self.request.status_code):
            return json.loads(self.request.content)
        return null
    def __del__(self):
        self.request.close()
