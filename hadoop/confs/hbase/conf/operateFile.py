#!/usr/bin/python

import pdb

class OperateFile:
    def __init__(self):
        self.fp = open('config.yaml', 'w')

    def write(self, dictData):
        for confKey in dictData:
            self.fp.write(confKey+':\n')
            data = dictData[confKey].split('\n')
            for li in range(len(data)):
                 self.fp.write('    '+data[li]+'\n')

    def __del__(self):
        self.fp.close()
