#~/usr/bin/python

from xml.dom.minidom import parse
from xml.dom.minidom import Document

import xml.dom.minidom
from xml.dom import minidom 
import collections
from config import hadoop_conf
import pdb

class OperateXML:

    readXmlDict = {}
    def __init__(self):
        conf_property = hadoop_conf['conf_property']
        self.propertys = conf_property.split(",")

    def __getElement(self, element, property):
        return element.getElementsByTagName(property)[0].childNodes[0].data

    def readXML(self, fileDir, fileName):
        self.readXmlDict.clear()
        domTree = xml.dom.minidom.parse(fileDir + "/" + fileName)
        collection = domTree.documentElement
        elements = collection.getElementsByTagName('property')
        if len(self.propertys) < 3:
            return 

        for element in elements:
            if element.getElementsByTagName(self.propertys[2]):
                value = self.__getElement(element, self.propertys[1]) + "#" + self.propertys[2]
            else :
                value = self.__getElement(element, self.propertys[1])
            self.readXmlDict[fileName + ":" + self.__getElement(element, self.propertys[0])] = value

        return self.readXmlDict

    def __orderDict(self, dictData):
        return collections.OrderedDict(sorted(dictData.items()))

    def writeXmlFileByDict(self, fileName, dictData):
        docTree = Document()
        xlstNode = docTree.createProcessingInstruction("xml-stylesheet", "type=\"text/xsl\" href=\"configuration.xsl\"")
        docTree.appendChild(xlstNode)
        config = docTree.createElement('configuration')
        docTree.appendChild(config)

        dictData = self.__orderDict(dictData)

        for (k, v) in dictData.iteritems(): 
            proList = docTree.createElement('property')
            config.appendChild(proList)
            proName = docTree.createElement(self.propertys[0])
            proList.appendChild(proName)
            proName_text = docTree.createTextNode(k)
            proName.appendChild(proName_text)

            proValue = docTree.createElement(self.propertys[1])
            proList.appendChild(proValue)
            value = v.split("#")
            if len(value) == 2:
                nodeValue = value[0]
                proFinal_text = docTree.createTextNode('true')
                proFinal = docTree.createElement(self.propertys[2])
                proFinal.appendChild(proFinal_text)
                proList.appendChild(proFinal)
            else :
                nodeValue = v    

            proValue_text = docTree.createTextNode(nodeValue)
            proValue.appendChild(proValue_text)
        
        xml.dom.minidom.Element.writexml = fixed_writexml

        with open(fileName, 'w') as f:
            docTree.writexml(f, addindent='\t',newl='\n') 
        f.close()

def fixed_writexml(self, writer, indent="", addindent="", newl=""):  
    writer.write(indent+"<" + self.tagName)  

    attrs = self._get_attributes()  
    a_names = attrs.keys()  
    a_names.sort()  

    for a_name in a_names:  
        writer.write(" %s=\"" % a_name)  
        minidom._write_data(writer, attrs[a_name].value)  
        writer.write("\"")  
    if self.childNodes:  
        if len(self.childNodes) == 1 \
            and self.childNodes[0].nodeType == minidom.Node.TEXT_NODE:  
                writer.write(">")  
                self.childNodes[0].writexml(writer, "", "", "")  
                writer.write("</%s>%s" % (self.tagName, newl))  
                return  
        writer.write(">%s"%(newl))  
        for node in self.childNodes:  
            if node.nodeType is not minidom.Node.TEXT_NODE:  
                node.writexml(writer, indent+addindent, addindent, newl)  
        writer.write("%s</%s>%s" % (indent, self.tagName, newl))  
    else:  
        writer.write("/>%s"%(newl))


if __name__ == "__main__":
    opXml = OperateXML()
    opXml.readXML("./tmp/core-site.xml")
