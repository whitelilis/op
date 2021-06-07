#!/usr/bin/python

import sys
sys.path.append("..")
from comm.operateXml import OperateXML
import os
import collections
import pdb

def file_name(file_dir):
    for root, dirs, files in os.walk(file_dir):
        print root 
        print files
        pass

    return root, files

def deal_file(file_dir, dataDict):
    root, files = file_name(file_dir)
    for fileName in files:
        confDict = opXml.readXML(root, fileName)
        dataDict.update(confDict)

if __name__ == "__main__":  

    opXml = OperateXML()
    totalDict = {}
    deal_file('../apollo-conf/tmp', totalDict)
    totalUserDict = {}
    deal_file('./user', totalUserDict)
    

    for key in totalUserDict.iterkeys():
        if totalDict.has_key(key):
           # print key
            del totalDict[key]
    
    totalDict.update(totalUserDict)

    resultDict = {}
    for key in totalDict:
        confValue = key.split(":")
        if resultDict.has_key(confValue[0]):
            resultDict[confValue[0]] += confValue[1]
        else :
            resultDict[confValue[0]] = confValue[1]
        resultDict[confValue[0]] += ":" + totalDict[key] + "\n"

   # print resultDict

    #pdb.set_trace()
    for confKey in resultDict:
        confList = resultDict[confKey].split('\n')
        dictConf = collections.OrderedDict()
        for li in range(len(confList)):
            proList = confList[li].split(":")
            if len(proList) == 2:
                dictConf[proList[0]] = proList[1]
        opXml.writeXmlFileByDict('./tmp/' + confKey, dictConf)
