#!/usr/local/bin/python
#encoding=utf-8

import sys, os, random, re, struct, socket

def isIntranet(ip):
    '''
    internal ip address
    192.168.0.0 - 192.168.255.255
    172.16.0.0  - 172.31.255.255
    10.0.0.0    - 10.255.255.255
    '''
    low192 = 3232235520L
    high192 = 3232301055L
    low172 = 2886729728L
    high172 = 2887778303L
    low10 = 167772160L
    high10 = 184549375L
    low127 = 2130706432L
    high127 = 2147483647L
    target = socket.ntohl(struct.unpack('I',socket.inet_aton(ip))[0])
    #if target > low192 and target < high192 or target > low172 and target < high172 or target > low10 and target < high10:
    if target > low127 and target < high127:
        return True
    return False

class Query:
    cmd = 'dig +nocmd %s %s +noall +answer'
    def dig(self, domain, type='A'):
        cmd = self.cmd %(domain, type)
        ret = ['>>> %s\n' %cmd]
        file = os.popen(cmd, 'r')
        ret.extend(file.readlines())
        file.close()
        return ret

    def digRBL(self, target):

        ret = []
        ipReg = re.compile('\d+.\d+.\d+.\d+')
        if ipReg.match(target) != None:
            ip = target
        else:
            domain = target + '.'
            rbl = 'multi.uribl.com'
            cmd = self.cmd %(domain+rbl, 'A')
            file = os.popen(cmd, 'r')
            records = file.readlines()
            ret.append('[INFO] 查询 %s\n' %rbl)
            ret.extend(records)
            if len(records) == 0 or not isIntranet(records[0].split()[-1]):
                ret.append('[INFO] 域名:%s 未被%s列入名单\n' %(target, rbl))
            else:
                ret.append('[INFO] 域名:%s **已被%s列入名单**\n' %(target, rbl))
            return ret

        ipReverse = ''
        for segment in ip.split('.'):
            ipReverse = segment + '.' + ipReverse
        rblList = [
            "zen.spamhaus.org",
            "bl.spamcannibal.org",
            "dnsbl.sorbs.net",
            "dnsbl-1.uceprotect.net",
            "dnsbl-2.uceprotect.net",
            "dnsbl-3.uceprotect.net",
            "bl.spamcop.net",
            "trendmicro.com",
            "multi.uribl.com",
            "cdl.anti-spam.org.cn",
            "cbl.anti-spam.org.cn",
        ]
        for rbl in rblList:
            ret.append('[INFO] 查询 %s\n' %rbl)
            cmd = self.cmd %(ipReverse+rbl, 'A')
            ret.append('>>> %s\n' %cmd)
            file = os.popen(cmd, 'r')
            records = file.readlines()
            ret.extend(records)
            if len(records) == 0 or not isIntranet(records[0].split()[-1]):
                ret.append('[INFO] ip:%s 未被%s列入名单\n' %(ip, rbl))
            else:
                ret.append('[INFO] ip:%s **已被%s列入名单**\n' %(ip, rbl))
            ret.append('\n')
        return ret


    def digPTR(self, domain):
        cmd = self.cmd %('-x', domain)
        ret = ['>>> %s\n' %cmd]
        file = os.popen(cmd, 'r')
        ret.extend(file.readlines())
        file.close()
        return ret

    def digSPF(self, domain):
        cmd = self.cmd %(domain, 'TXT')
        ret = ['>>> %s\n' %cmd]
        file = os.popen(cmd)
        line = file.readline()
        while line != '':
            spf = line.split('\t')[-1].strip("\n\"").split(" ", 1)
            if 'spf' in spf[0]:
                ret.append(line+'\n')
                records = spf[1].split()
                pattern = re.compile("(include:|redirect=)(.*)")
                for record in records:
                    result = pattern.match(record)
                    if result:
                        ret.extend(self.digSPF(result.group(2)))
                break
            line = file.readline()
        file.close()
        return ret

    def digDMARC(self, domain):
        cmd = self.cmd %('_dmarc.'+domain, 'TXT')
        ret = ['>>> %s\n' %cmd]
        file = os.popen(cmd, 'r')
        ret.extend(file.readlines())
        file.close()
        return ret

    def printDig(self, domain, type='A'):
        if type == 'PTR':
            ret = self.digPTR(domain)
        elif type == 'SPF':
            ret = self.digSPF(domain)
        elif type == 'RBL':
            ret = self.digRBL(domain)
        elif type == 'DMARC':
            ret = self.digDMARC(domain)
        else:
            ret = self.dig(domain, type)
        if len(ret) == 1:
            sys.stdout.write(ret[0])
            print '[INFO] 无对应记录'
            return
        for line in ret:
            sys.stdout.write(line)

    def pickOneMX(self, domain):
        cmd = self.cmd %(domain, 'MX')
        file = os.popen(cmd, 'r')
        ret = file.readlines()
        file.close()
        if len(ret) == 0:
            return None
        rand = random.randint(0, len(ret)-1)
        return ret[rand].split()[-1]

if __name__ == '__main__':
    test = Query()
    if len(sys.argv) == 2:
        test.printDig(sys.argv[1])
    elif len(sys.argv) == 3:
        test.printDig(sys.argv[1], sys.argv[2])
