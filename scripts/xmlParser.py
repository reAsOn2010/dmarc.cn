#!/usr/local/bin/python
#ecnoding=utf8

import json, os
import xml.etree.ElementTree as ET
class XMLParser(object):
    def __init__(self, file):
        self.root = ET.parse(file).getroot()
        self.meta = self._formatMeta(self.root.find('report_metadata'))
        self.policy = self.root.find('policy_published')
        self.records = self._formatRecords(self.root.findall('record'))
    def _formatMeta(self, meta):
        result = {}
        result['org_name'] = meta.find('org_name').text
        result['email'] = meta.find('email').text
        result['report_id'] = meta.find('report_id').text
        return result
    def _formatPolicy(self):
        pass
    def _formatRecords(self, records):
        result = []
        for record in records:
            temp = {}
            temp['ip'] = record.find('./row/source_ip').text
            #file = os.popen('dig +nocmd -x %s +noall +answer' % temp['ip'])
            #dig = file.readline()
            #if dig != '':
            #    temp['domain'] = dig.split()[-1]
            #else:
            #    temp['domain'] = ''
            result.append(temp)
        return result
    def printAll(self):
        print self.meta
        print self.records
    def metaData(self):
        pass
    def JSON(self):
        json.dumps([])

if __name__ == '__main__':
    parser = XMLParser('../163.com!amazon.com!1374595200!1374681599.xml')
    parser.printAll()
