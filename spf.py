#!/usr/bin/python
#encoding=utf-8
import os, re, sys

def dig_loop(domain):
    cmd = 'dig +nocmd %s TXT +noall +answer' %(domain)
    print ">>> %s" %(cmd)
    ret = os.popen(cmd)
    line = ret.readline()
    while line != '':
        #pattern = re.compile(".*\"(v=spf1 |spf2.0/pra )((include:(.* ))[-~]all|redirect=(.*))\"")
        spf = line.split('\t')[-1].strip("\n\"").split(" ", 1)
        if 'spf' in spf[0]:
            print line
            records = spf[1].split()
            #print records
            pattern = re.compile("(include:|redirect=)(.*)")
            for record in records:
                result = pattern.match(record)
                if result:
                    dig_loop(result.group(2))
        #    patten = re.compile("(include:|redirect=)(.*)")
        #    print data
            break
        line = ret.readline()

if __name__=='__main__':
    if len(sys.argv) == 2:
        dig_loop(sys.argv[1])
