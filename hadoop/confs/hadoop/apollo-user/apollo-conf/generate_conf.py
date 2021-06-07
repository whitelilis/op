#!/usr/bin/python

import sys
sys.path.append("..")
from comm.requestApollo import RequestApollo
from comm.operateXml import OperateXML
import collections

if __name__ == "__main__":
    requestApollo = RequestApollo()
    dictData = requestApollo.getDict()
    opXml = OperateXML()
    for confKey in dictData:
        confList = dictData[confKey].split('\n')
        dictConf = collections.OrderedDict()
        for li in range(len(confList)):
            proList = confList[li].split(":")
            if (len(proList) > 2):
                proList[1] = ":".join(proList[1:len(proList)])
            dictConf[proList[0]] = proList[1].strip().strip("\"")
        opXml.writeXmlFileByDict('./tmp/' + confKey, dictConf)
