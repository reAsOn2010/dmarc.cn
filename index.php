<html>
<head>
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
    $all = document.getElementsByClassName("my-form");
    for (var $i=0; $i < $all.length; $i++) {
        $all[$i].style.display = "none";
    }
}
function show(id) {
    hideAll();
    $target = document.getElementById(id);
    $target.style.display = "";
}
window.onload = function() {
    console.log(getParameter($_get, 'domain') != null);
    if ($_get == "" || getParameter($_get, 'domain') != null) {
        show('dns-form');
        document.getElementById('dns-input').value = getParameter($_get, 'domain');
        $select = document.getElementById('dns-select');
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
        $select = document.getElementById('rbl-select');
        for (var $i = 0; $i < $select.length; $i++) {
            console.log($select[$i].value + " " + getParameter($_get, 'rbl'));
            if ($select[$i].value == getParameter($_get, 'rbl')) {
                $select[$i].selected = true;
            }
        }
        show('rbl-form');
    }
    else if (getParameter($_get, 'smtp') != null) {
        document.getElementById('smtp-input').value = getParameter($_get, 'ip-rbl');
        $select = document.getElementById('smtp-select');
        for (var $i = 0; $i < $select.length; $i++) {
            if ($select[$i].value == getParameter($_get, 'type')) {
                $select[$i].selected = true;
            }
        }
        show('smtp-form');
    }
}
</script>
</head>
<body>
<div class="top-nav">
<button onclick="show('dns-form');">DNS</button>
<button onclick="show('rdns-form');">Reverse DNS</button>
<button onclick="show('rbl-form');">RBL</button>
<button onclick="show('smtp-form');">SMTP port 25 test</button>
</div>
<form class="my-form" id="dns-form">
<fieldset>
<legend>DNS</legend>
Domain: <input id="dns-input" type="text" name="domain"></input>
Type: <select id="dns-select" name="type">
<option value="A">A</option>
<option value="MX">MX</option>
<option value="SPF">SPF</option>
</select>
</br>
<input type="submit" value="query"></input>
</fieldset>
</form>
<form class="my-form" id="rdns-form">
<fieldset>
<legend>Reverse DNS</legend>
IP for PRT: <input id="rdns-input" type="text" name="ip-ptr"></input>
</br>
<input type="submit" value="query"></input>
</fieldset>
</form>
<form class="my-form" id="rbl-form">
<fieldset>
<legend>RBL</legend>
IP for RBL: <input id="rbl-input" type="text" name="ip-rbl">
<select id="rbl-select" name="rbl">
<option value="cbl">cbl</option>
<option value="cblplus">cblplus</option>
<option value="cml">cml</option>
</select>
</br>
<input type="submit" value="query"></input>
</fieldset>
</form>
<form class="my-form" id="smtp-form">
<fieldset>
<legend>SMTP port 25 test</legend>
SMTP server: <input id="smtp-input" type="text" name="smtp"></input>
<select id="smtp-select" name="type">
<option value="1">EHLO</option>
<option value="0">HELO</option>
</select>
</br>
<input type="submit" value="query">
</fieldset>
</form>

<textarea rows="16" cols="128" readonly="readonly">
<?php
if (isset($_GET["domain"]) && !empty($_GET["domain"])) {
    $domain = $_GET["domain"];
    $type = $_GET["type"];
    if ($type == "A" || $type == "MX") {
        $cmd = "dig +nocmd $domain $type +noall +answer";
        echo ">>> $cmd\n";
    }
    else if ($type == "SPF")
        //$cmd = "dig +nocmd $domain TXT +noall +answer | grep spf ";
        $cmd = "./spf.py $domain";
    $file = popen($cmd, "r");
    while(!feof($file))
    {
        echo fgets($file);
    }
    fclose($file);
}
else if (isset($_GET["ip-ptr"]) && !empty($_GET["ip-ptr"])) {
    $ip = $_GET["ip-ptr"];
    $cmd = "dig +nocmd -x $ip +noall +answer";
    echo ">>> $cmd\n";
    $file = popen($cmd, "r");
    while(!feof($file))
    {
        echo fgets($file);
    }
    fclose($file);
}

else if (isset($_GET["ip-rbl"]) && !empty($_GET["ip-rbl"])) {
    $rbl_list=array(
        "cbl"=>"cbl.anti-spam.org.cn",
        "cdl"=>"cdl.anti-spam.org.cn",
        "cml"=>"cml.anti-spam.org.cn",
        "cblplus"=>"cblplus.anti-spam.org.cn",
        "cblless"=>"cblless.anti-spam.org.cn"
    );
    $ip = $_GET["ip-rbl"];
    $token = strtok($ip, ".");
    $ip_reverse = "";
    while ($token !== false) {
        $ip_reverse = $token . "." . $ip_reverse;
        $token = strtok(".");
    }
    $rbl = $_GET["rbl"];
    $cmd = "dig +nocmd $ip_reverse" . $rbl_list[$rbl] . " +noall +answer";
    echo ">>> $cmd\n";
    $file = popen($cmd, "r");
    while(!feof($file))
    {
        echo fgets($file);
    }
    fclose($file);
}

else if (isset($_GET["smtp"]) && !empty($_GET["smtp"])) {
    $smtp = $_GET["smtp"];
    $type = $_GET["type"];
    $cmd = "./test25.py $smtp $type";
    $file = popen($cmd, "r");
    while(!feof($file))
    {
        echo fgets($file);
    }
    fclose($file);
}
?>
</textarea>

</body>
</html>
