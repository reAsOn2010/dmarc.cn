<html>
<head>
    <title>DNS查询系统</title>
    {include file="header.tpl"}
    <script>
    var $queryString = window.top.location.search.substring(1);
    var $_get = $queryString.split("&");
    function getParameter($_get, $param) {
        for (var $i = 0; $i < $_get.length; $i++) {
            $pair = $_get[$i].split("=");
            if ($pair[0] == $param)
                return $pair[1];
        }
        return null
    }
    function toggle($target) {
        if ($target.style.display == "none")
            $target.style.display = "";
        else if ($target.style.display == "")
            $target.style.display = "none";
    }
    function hideAll() {
        var $all = document.getElementsByClassName("my-form");
        for (var $i=0; $i < $all.length; $i++) {
            $all[$i].style.display = "none";
        }
        document.getElementById("rbl-help").style.display = "none";
    }
    function show(id) {
        hideAll();
        var $target = document.getElementById(id);
        $target.style.display = "";
        document.getElementById("result-area").style.display = "";
    }
    window.onload = function() {
        if ($_get == "" || getParameter($_get, 'domain') != null) {
            show('dns-form');
            document.getElementById('dns-input').value = getParameter($_get, 'domain');
            var $select = document.getElementById('dns-select');
            for (var $i = 0; $i < $select.length; $i++) {
                if ($select[$i].value == getParameter($_get, 'type')) {
                    $select[$i].selected = true;
                }
            }
        }
        else if (getParameter($_get, 'ip-ptr') != null) {
            document.getElementById('rdns-input').value = getParameter($_get, 'ip-ptr');
            show('rdns-form');
        }
        else if (getParameter($_get, 'ip-rbl') != null) {
            document.getElementById('rbl-input').value = getParameter($_get, 'ip-rbl');
            show('rbl-form');
            document.getElementById("rbl-help").style.display = "";
        }
        else if (getParameter($_get, 'port25') != null) {
            document.getElementById('port25-input').value = getParameter($_get, 'port25');
            show('port25-form');
        }
        else if (getParameter($_get, 'dmarc-gen-domain') != null) {
            show('dmarc-gen-form');
        }
        else if (getParameter($_get, 'dkim-domain') != null) {
            document.getElementById('dkim-domain').value = getParameter($_get, 'dkim-domain');
            document.getElementById('selector').value = getParameter($_get, 'selector');
            show('dkim-form');
        }
        else if (getParameter($_get, 'xml') != null) {
            show('xml-form');
            document.getElementById("result-area").style.display = "none";
        }
    }
    </script>
</head>
<body>
    <span class="txt">
        <strong>DNS查询系统</strong>
    </span>
    <input type="button" onclick="show('dns-form');" value="DNS查询"></input>
    <input type="button" onclick="show('rdns-form');" value="IP PTR查询"></input>
    <input type="button" onclick="show('rbl-form'); document.getElementById('rbl-help').style.display=''; " value="RBL记录查询"></input>
    <input type="button" onclick="show('port25-form');" value="25号端口测试"></input>
    <input type="button" onclick="show('dkim-form');" value="DKIM KEY查询"></input>
    <input type="button" onclick="show('dmarc-gen-form');" value="DMARC记录生成器"></input>
    <input type="button" onclick="show('xml-form'); document.getElementById('result-area').style.display = 'none';" value="DMARC报告查看器"></input>

    <form class="my-form" id="dns-form" style="display:none">
        <fieldset>
            <legend>DNS查询</legend>
            目标域名: <input id="dns-input" type="text" name="domain"></input>
            记录类型: <select id="dns-select" name="type">
                <option value="A">A记录</option>
                <option value="MX" selected>MX记录</option>
                <option value="SPF">SPF记录</option>
                <option value="DMARC">DMARC记录</option>
            </select>
            </br>
            <input type="submit" value="查询"></input>
        </fieldset>
    </form>

    <form class="my-form" id="rdns-form" style="display:none">
        <fieldset>
            <legend>IP PTR查询</legend>
            目标IP: <input id="rdns-input" type="text" name="ip-ptr"></input>
            </br>
            <input type="submit" value="查询"></input>
        </fieldset>
    </form>

    <form class="my-form" id="rbl-form" style="display:none">
        <fieldset>
            <legend>RBL记录查询</legend>
            目标IP 或 域名: <input id="rbl-input" type="text" name="ip-rbl">
            </br>
            <input type="submit" value="查询"></input>
        </fieldset>
    </form>

    <form class="my-form" id="port25-form" style="display:none">
        <fieldset>
            <legend>25号端口测试</legend>
            目标域名: <input id="port25-input" type="text" name="port25"></input>
            </br>
            <input type="submit" value="测试">
        </fieldset>
    </form>

    <form class="my-form" id="dmarc-gen-form" style="display:none">
        <fieldset>
            <legend>DMARC记录生成器</legend>
            <table border="0" width="460">
            <tbody>
                <tr>
                    <td align="right">域名:</td>
                    <td> <input name="dmarc-gen-domain" size="30" type="text"></td>
                </tr>
                <tr>
                    <td align="left"><b>必要字段</b></td>
                </tr>
                <tr>
                    <td align="right"><span title="Requested Mail Receiver policy (plain-text; REQUIRED).  Indicates the policy to be enacted by the Receiver at the request of the Domain Owner.  Policy applies to the domain queried and to sub- domains unless sub-domain policy is explicitly described using the 'sp' tag.">Requested policy type:</span><br>
                    </td>
                    <td> 
                    <input type="radio" name="policy" value="none"><span title="none: The Domain Owner requests no specific action be taken regarding delivery of messages.">none</span>
                    <input type="radio" name="policy" value="quarantine"> <span title="quarantine: The Domain Owner wishes to have email that fails the DMARC mechanism check to be treated by Mail Receivers as suspicious.  Depending on the capabilities of the Mail Receiver, this can mean 'place into spam folder', 'scrutinize with additional intensity', and/or 'flag as suspicious'.">quarantine</span>
                    <input type="radio" name="policy" value="reject"> <span title="reject: The Domain Owner wishes for Mail Receivers to reject email that fails the DMARC mechanism check.  Rejection SHOULD occur during the SMTP transaction.">reject</span>
                    </td>
                </tr>
                <tr>
                    <td align="left"><b>可选字段</b></td>
                </tr>
                <tr>
                    <td align="right"><span title="rua:  Addresses to which aggregate feedback is to be sent (comma-separated plain-text list of DMARC URIs; OPTIONAL). {literal}{R11}{/literal} A comma or exclamation point that is part of such a DMARC URI MUST be encoded per Section 2.1 of [URI] so as to distinguish it from the list delimiter or an OPTIONAL size limit.  Section 8.2 discusses considerations that apply when the domain name of a URI differs from that of the domain advertising the policy.  See Section 15.6 for additional considerations.  Any valid URI can be specified.  A Mail Receiver MUST implement support for a 'mailto:' URI, i.e. the ability to send a DMARC report via electronic mail.  If not provided, Mail Receivers MUST NOT generate aggregate feedback reports.">Aggregate Data Reporting Address:</span></td>
                    <td> <input name="rua" size="30" type="text"></td>
                </tr>
                <tr>
                    <td align="right"><span title="Warning: May be very high volume - the ruf address must be prepared to receive a LOT of mail.
                    ruf:  Addresses to which message-specific forensic information is to be reported (comma-separated plain-text list of DMARC URIs; OPTIONAL). If present, the Domain Owner is requesting Mail Receivers to send detailed forensic reports about messages that fail [SPF] and/or [DKIM] evaluation.  The format of the message to be generated MUST follow that specified in the 'rf' tag.  Section 8.2 discusses considerations that apply when the domain name of a URI differs from that of the domain advertising the policy.  A Mail Receiver MUST implement support for a 'mailto:' URI, i.e. the ability to send a DMARC report via electronic mail.  If not provided, Mail Receivers MUST NOT generate forensic reports.">Forensic Data Reporting Address:</span><br>
                    </td>
                    <td> <input name="ruf" size="30" type="text"></td>
                </tr>
                <tr><td align="right"><span title="adkim:  (plain-text; OPTIONAL, default is 'r'.)  Indicates whether or not strict DKIM identifier alignment is required by the Domain Owner.  If and only if the value of the string is 's', strict mode is in use.">DKIM identifier alignment:</span><br>
                    </td>
                    <td> 
                    <input type="radio" name="adkim" value="r"><span title="In relaxed mode, the Organizational Domain of the [DKIM]- authenticated signing domain (taken from the value of the 'd=' tag in the signature) and that of the RFC5322.From domain must be equal.  In strict mode, only an exact match is considered to produce identifier alignment.">relaxed (default)</span>
                    <input type="radio" name="adkim" value="s"><span title="In relaxed mode, the Organizational Domain of the [DKIM]- authenticated signing domain (taken from the value of the 'd=' tag in the signature) and that of the RFC5322.From domain must be equal.  In strict mode, only an exact match is considered to produce identifier alignment.">strict</span>
                    </td>
                </tr>
                <tr>
                    <td align="right"><span title="aspf:  (plain-text; OPTIONAL, default is 'r'.)  Indicates whether or not strict SPF identifier alignment is required by the Domain Owner.  If and only if the value of the string is 's', strict mode is in use.">SPF identifier alignment:</span><br>
                    </td>
                    <td> 
                    <input type="radio" name="aspf" value="r"> <span title="In relaxed mode, the [SPF]-authenticated RFC5321.MailFrom (commonly called the 'envelope sender') domain and RFC5322.From domain must have the same Organizational Domain.  In strict mode, only an exact DNS domain match is considered to produce identifier alignment.">relaxed (default)</span>
                    <input type="radio" name="aspf" value="s"> <span title="In relaxed mode, the [SPF]-authenticated RFC5321.MailFrom (commonly called the 'envelope sender') domain and RFC5322.From domain must have the same Organizational Domain.  In strict mode, only an exact DNS domain match is considered to produce identifier alignment.">strict</span>
                    </td>
                </tr>
                <tr>
                    <td align="right"><span title="rf:  Format to be used for message-specific forensic information reports (comma-separated plain-text list of values; OPTIONAL; default 'afrf').  The value of this tag is a list of one or more report formats as requested by the Domain Owner to be used when a message fails both [SPF] and [DKIM] tests to report details of the individual failure.">Report Format:<br>
                    </span></td>
                    <td> 
                    <input type="checkbox" name="rfarf" value="afrf"><span title="[ARF]  Shafranovich, Y., Levine, J., and M. Kucherawy, 'An Extensible Format for Email Feedback Reports', RFC 5965, August 2010. afrf (default)">afrf (default)</span>
                    <input type="checkbox" name="rfiodef" value="iodef"><span title="[IODEF] Danyliw, R., Meijer, J., and Y. Demchenko, 'The Incident Object Description Exchange Format', RFC 5070, December 2007.">iodef</span>
                    </td>
                </tr>
                <tr>
                    <td align="right"><span title="pct:  (plain-text integer between 0 and 100, inclusive; OPTIONAL; default is 100). {literal}{R8}{/literal} Percentage of messages from the DNS domain's mail stream to which the DMARC mechanism is to be applied.  However, this MUST NOT be applied to the DMARC-generated reports, all of which must be sent and received unhindered.  The purpose of the 'pct' tag is to allow Domain Owners to slowly roll out enforcement of the DMARC mechanism.  The prospect of 'all or nothing' is recognized as preventing many organizations from experimenting with strong authentication-based mechanisms">Apply Policy to this Percentage:</span></td>
                    <td> <input name="pct" size="5" type="text"><span title="pct:  (plain-text integer between 0 and 100, inclusive; OPTIONAL; default is 100). {literal}{R8}{/literal} Percentage of messages from the DNS domain's mail stream to which the DMARC mechanism is to be applied.  However, this MUST NOT be applied to the DMARC-generated reports, all of which must be sent and received unhindered.  The purpose of the 'pct' tag is to allow Domain Owners to slowly roll out enforcement of the DMARC mechanism.  The prospect of 'all or nothing' is recognized as preventing many organizations from experimenting with strong authentication-based mechanisms">% (100 default)</span></td>
                </tr>
                <tr>
                    <td align="right"><span title="ri:  Interval requested between aggregate reports (plain-text, 32-bit unsigned integer; OPTIONAL; default 86400).Indicates a request to Receivers to generate aggregate reports separated by no more than the requested number of seconds.  DMARC implementations MUST be able to provide daily reports and SHOULD be able to provide hourly reports when requested.  However, anything other than a daily report is understood to be accommodated on a best-effort basis.">Reporting Interval (default=86400):</span></td>
                    <td> <input name="ri" size="10" type="text"><span title="ri:  Interval requested between aggregate reports (plain-text, 32-bit unsigned integer; OPTIONAL; default 86400).Indicates a request to Receivers to generate aggregate reports separated by no more than the requested number of seconds.  DMARC implementations MUST be able to provide daily reports and SHOULD be able to provide hourly reports when requested.  However, anything other than a daily report is understood to be accommodated on a best-effort basis.">Seconds</span></td>
                </tr>
                <tr>
                    <td align="right"><span title="sp:  Requested Mail Receiver policy for subdomains (plain-text; OPTIONAL).  Indicates the policy to be enacted by the Receiver at the request of the Domain Owner.  It applies only to subdomains of the domain queried and not to the domain itself.  Its syntax is identical to that of the 'p' tag defined above.  If absent, the policy specified by the 'p' tag MUST be applied for subdomains.">Subdomain Policy:<br>
                    Defaults to same as domain <br></span></td>
                    <td>
                    <input type="radio" name="sp" value="none"><span title="none: The Domain Owner requests no specific action be taken regarding delivery of messages.">none</span>
                    <input type="radio" name="sp" value="quarantine"> <span title="quarantine: The Domain Owner wishes to have email that fails the DMARC mechanism check to be treated by Mail Receivers as suspicious.  Depending on the capabilities of the Mail Receiver, this can mean 'place into spam folder', 'scrutinize with additional intensity', and/or 'flag as suspicious'.">quarantine</span>
                    <input type="radio" name="sp" value="reject"> <span title="reject: The Domain Owner wishes for Mail Receivers to reject email that fails the DMARC mechanism check.  Rejection SHOULD occur during the SMTP transaction.">reject</span>
                </td></tr>
                    <tr>
                    <td> <input value="Get DMARC Record" type="submit"></td>
                </tr>
            </tbody>
            </table>
        </fieldset>
    </form>

    <form class="my-form" id="dkim-form" style="display:none">
        <fieldset>
            <legend>DKIM KEY查询</legend>
            SELECTOR:<input id="selector" type="text" name="selector"></input>
            域名:<input id="dkim-domain" type="text" name="dkim-domain"></input>
            </br>
            <input type="submit" value="查询"></input>
        </fieldset>
    </form>

    <form class="my-form" method="post" action="xml.php" id="xml-form" style="display:none" enctype="multipart/form-data">
        <fieldset>
            <legend>DMARC报告查看器</legend>
            <label for="file">XML文件上传:</label>
            <input type="file" name="xml-file" id="file" />
            <br/>
            <input type="submit" name="submit" value="上传" />
        </fieldset>
    </form>

    <hr>

    <textarea id="result-area" cols="96" rows="30" readonly="readonly" style="float:left" >
{$result}
    </textarea>

    <div id="rbl-help" style="float:left;margin-left:50px">
        <div style="float:left">
            IP-RBL查询列表:</br>
            zen.spamhaus.org</br>
            bl.spamcannibal.org</br>
            dnsbl.sorbs.net</br>
            dnsbl-1.uceprotect.net</br>
            dnsbl-2.uceprotect.net</br>
            dnsbl-3.uceprotect.net</br>
            bl.spamcop.net</br>
            trendmicro.com</br>
            multi.uribl.com</br>
            cdl.anti-spam.org.cn</br>
            cbl.anti-spam.org.cn</br>
        </div>
        <div style="float:left; margin-left:50px">
            域名RBL查询列表:</br>
            multi.uribl.com</br>
        </div>
    </div>


