#!/usr/local/bin/python
#encoding=utf-8

import socket, telnetlib, sys, os
import dnsquery

def writeAndTest(conn, msg):
    conn.write(msg+'\r\n')
    print ">>>",msg
    try:
        readAndTest(conn)
    except ValueError, e:
        print e , 'Incorrect response when testing "%s"' %(msg)
        sys.exit(1)

def writeWithoutTest(conn, msg):
    conn.write(msg+'\r\n')
    print ">>>", msg
    readAll(conn)

def readAll(conn):
    ret = ''
    ret += conn.read_some()
    while True:
        tmp = conn.read_eager()
        if tmp != '':
            ret += tmp
        else:
            break
    return ret

def readAndTest(conn):
    tmp = readAll(conn)
    print tmp
    if tmp[0:3] != '250':
        raise ValueError('[Test Failed]')

def testPort25(host, domain):
    '''
    test port 25 of the host
    '''

    print '>>> telnet %s 25' %(host)
    socket.setdefaulttimeout(5)
    conn = telnetlib.Telnet(host, port=25)
    conn.get_socket().settimeout(5)

    print readAll(conn)
    print '[INFO] 测试 HELO 指令'
    writeAndTest(conn, 'helo ' + host)
    print '[INFO] 测试 MAIL FROM 指令'
    writeAndTest(conn, 'mail from:<%s>' %('abuse@zslzslzsl.com'))
    print '[INFO] 测试 RCPT TO 指令'
    writeAndTest(conn, 'rcpt to:<%s>' %('abuse@'+domain))
    writeWithoutTest(conn, 'quit')

def testDomain(domain):
    query = dnsquery.Query()
    mxServer = query.pickOneMX(domain)
    if mxServer == None:
        print '[INFO] 无MX服务器可用'
    else:
        print '[INFO] 测试MX服务器: %s' %mxServer
        testPort25(mxServer, domain)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print '---开始---'
        try:
            testDomain('163.com')
        except socket.error, e:
            print e
            print "[INFO] 超时! 请检查域名地址和网络连接"
        print '---结束---'
    elif len(sys.argv) == 2:
        print '---开始---'
        try:
            testDomain(sys.argv[1])
        except socket.error, e:
            print e
            print "[INFO] 超时! 请检查域名地址和网络连接"
        print '---结束---'
