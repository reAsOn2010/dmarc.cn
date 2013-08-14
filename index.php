<?php
session_start();
/*

function checksession() {
    if (isset($_SESSION['cxlm_logined_corpmail']) and !empty($_SESSION['cxlm_logined_corpmail'])) {
        return true;
    }
    return false;
}

# 获得用户原始IP
function getRealIp(){
    $ip=false;
    if(!empty($_SERVER["HTTP_CLIENT_IP"])){
        $ip = $_SERVER["HTTP_CLIENT_IP"];
    }
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ips = explode (", ", $_SERVER['HTTP_X_FORWARDED_FOR']);
            if ($ip) { array_unshift($ips, $ip); $ip = FALSE; }
            for ($i = 0; $i < count($ips); $i++) {
                if (!eregi ("^(10\.|172\.16|192\.168)\.", $ips[$i])) {
                    $ip = $ips[$i];
                    break;
                }
            }
    }
    return ($ip ? $ip : $_SERVER['REMOTE_ADDR']);
}

// 仅限公司办公内网访问
$WhiteIPList = array(
    '218.107.55.253',
    '218.107.55.254',
    '113.108.224.230',
    '59.42.177.211',
    '112.64.161.210',
    '112.64.161.211',
    '114.113.197.131',
    '114.113.197.132',
    '61.135.255.84',
    '61.135.255.86',
    '61.135.255.88',
    '203.86.46.130',
    '203.86.63.98',
    '123.58.191.69',
);
$userIP = getRealIp();
if(!in_array($userIP, $WhiteIPList)){
    header("Content-Type: text/html; charset=utf-8");
    print "你的IP($userIP)不被允许访问！";
    exit();
}
if(!checksession()){
    header("Location: https://kefu.mail.netease.com/cxlm/index.php");
    exit();
}
*/

//Smarty配置
require('./libs/Smarty.class.php');
$smarty = new Smarty();
$smarty->template_dir ="./templates";
$smarty->compile_dir ="./templates_c";
$smarty->config_dir = "./config";
$smarty->cache_dir ="./cache";

$result = "";

function readAllFromPipe($target) {
    $result = "";
    $file = popen($target, "r");
    while (!feof($file)) {
        $result .= fgets($file);
    }
    fclose($file);
    return $result;
}

//DNS查询功能
if (isset($_GET["domain"]) && !empty($_GET["domain"])) {
    $domain = $_GET["domain"];
    $type = $_GET["type"];
    $cmd = "./scripts/dnsquery.py $domain $type";
    $result = readAllFromPipe($cmd);
}

//PTR查询功能
else if (isset($_GET["ip-ptr"]) && !empty($_GET["ip-ptr"])) {
    $ip = $_GET["ip-ptr"];
    $cmd = "./scripts/dnsquery.py $ip PTR";
    $result = readAllFromPipe($cmd);
}

//
else if (isset($_GET["ip-rbl"]) && !empty($_GET["ip-rbl"])) {
    $ip = $_GET["ip-rbl"];
    $cmd = "./scripts/dnsquery.py $ip RBL";
    $result = readAllFromPipe($cmd);
}

else if (isset($_GET["port25"]) && !empty($_GET["port25"])) {
    $domain = $_GET["port25"];
    $cmd = "./scripts/test25.py $domain";
    $result = readAllFromPipe($cmd);
}

else if (isset($_GET["dmarc-gen-domain"]) && !empty($_GET["dmarc-gen-domain"])) {
    if (!isset($_GET["policy"]))
        $result .= "[INFO] Policy是必填字段\n";
    else {
        $result .= "DMARC记录生成结果:\n\n";
        $result .= $_GET["dmarc-gen-domain"]."的DMARC记录\n";
        $result .= "该记录应该在_dmarc.".$_GET["dmarc-gen-domain"]."中\n\n";
        $record = "v=DMARC1; p=".$_GET["policy"];
        if (!empty($_GET["rua"]))
            $record .= "; rua=mailto:".$_GET["rua"];
        if (!empty($_GET["ruf"]))
            $record .= "; ruf=mailto:".$_GET["ruf"];
        if (!empty($_GET["adkim"]))
            $record .= "; adkim=".$_GET["adkim"];
        if (!empty($_GET["aspf"]))
            $record .= "; aspf=".$_GET["aspf"];
        if (!isset($_GET["rfarf"]) && !isset($_GET["rfiodef"])) {
        }
        else if (isset($_GET["rfarf"]) && isset($_GET["rfiodef"]))
            $record .= "; rf=afrf,iodef";
        else if (!isset($_GET["rfarf"]) && isset($_GET["rfiodef"]))
            $record .= "; rf=afrf";
        else if (isset($_GET["rfarf"]) && !isset($_GET["rfiodef"]))
            $record .= "; rf=iodef";
        if (!empty($_GET["pct"]))
            $record .= "; pct=".$_GET["pct"];
        if (!empty($_GET["ri"]))
            $record .= "; ri=".$_GET["ri"];
        if (!empty($_GET["sp"]))
            $record .= "; sp=".$_GET["sp"];
        $result .= $record."\n\n";
        if (!empty($_GET["ruf"])) {
            $splitedAddr = explode("@", $_GET["ruf"]);
            $result .= $splitedAddr[1]."需要添加认证记录:\n\n";
            $result .= $_GET["dmarc-gen-domain"]."._report._dmarc.".$splitedAddr[1]."\n\n";
        }
    }
}

else if (isset($_GET["dkim-domain"]) && !empty($_GET["dkim-domain"])) {
    $selector = $_GET["selector"];
    $domain = $_GET["dkim-domain"];
    $cmd = "./scripts/dnsquery.py $selector._domainkey.$domain TXT";
    $result = readAllFromPipe($cmd);
}

$smarty->assign("result", $result);
$smarty->display("dns.tpl");

?>

