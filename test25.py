#!/usr/bin/python
#encoding=utf-8

import socket, telnetlib, sys

def writeAndRead(conn, msg):
    conn.write(msg+'\r\n')
    print ">>>",msg
    myReadAll(conn)

def myReadAll(conn):
    print conn.read_some()
    while True:
        tmp = conn.read_eager()
        if tmp != '':
            print tmp
        else:
            break

def testPort25(host, mode=1):
    '''
    test port 25 of the host
    '''
    socket.setdefaulttimeout(5)
    conn = telnetlib.Telnet(host, port=25)
    conn.get_socket().settimeout(5)

    myReadAll(conn)
    if mode == 1:
        writeAndRead(conn, 'EHLO ' + host)
    elif mode == 0:
        writeAndRead(conn, 'HELO ' + host)

    conn.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'default test of smtp.163.com\n'
        print '---begin---'
        try:
            testPort25('smtp.163.com')
        except socket.error, e:
            print "[ERROR] Timeout! Check the host and the network!"
        print '---end---'
    elif len(sys.argv) == 2:
        print 'test of %s\n' %(sys.argv[1])
        print '---begin---'
        try:
            testPort25(sys.argv[1])
        except socket.error, e:
            print "[ERROR] Timeout! Check the host and the network!"
        print '---end---'
    elif len(sys.argv) == 3:
        print 'test of %s\n' %(sys.argv[1])
        print '---begin---'
        try:
            testPort25(sys.argv[1], mode=int(sys.argv[2]))
        except socket.error, e:
            print "[ERROR] Timeout! Check the host and the network!"
        print '---end---'
