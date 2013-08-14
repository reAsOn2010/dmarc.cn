<?php

require('./libs/Smarty.class.php');
$smarty = new Smarty();

function readAllFromPipe($target) {
    $result = "";
    $file = popen($target, "r");
    while (!feof($file)) {
        $result .= fgets($file);
    }
    fclose($file);
    return $result;
}

if ($_FILES["xml-file"]["size"]==0 || $_FILES["xml-file"]["type"] != "text/xml")
    header("Location: /?xml=");
$xml = simplexml_load_file($_FILES["xml-file"]["tmp_name"]);
$metadata = $xml->report_metadata;
$policydata = $xml->policy_published;

$report_id = str_replace(">", "&gt;", str_replace("<", "&lt;", (string)$metadata->report_id));

$meta["org_name"] = (string)$metadata->org_name;
$meta["email"] = (string)$metadata->email;
$meta["extra_info"] = (string)$metadata->extra_contact_info;
$meta["report_id"] = $report_id;
$meta["date"] = gmdate("M d Y H:i:s", (int)$metadata->date_range->begin) . " to " . gmdate("M d Y H:i:s", (int)$metadata->date_range->end);

$smarty->assign("meta", $meta);

$policy["domain"] = (string)$policydata->domain;
$policy["policy"] = (string)$policydata->p;
$policy["dkim"] = ((string)$policydata->adkim == "r") ? "Relax" : "Strict";
$policy["spf"] = ((string)$policydata->aspf == "r") ? "Relax" : "Strict";
$policy["percentage"] = (string)$policydata->pct;

$records = Array();
$total = 0;
$success_total = 0;
$dkim_fail_total = 0;
$spf_fail_total = 0;
foreach ($xml->record as $record) {
    $ip = (string)$record->row->source_ip;
    $count = (int)$record->row->count;
    $dkim = (string)$record->auth_results->dkim->domain;
    $result_dkim = (string)$record->row->policy_evaluated->dkim;
    $result_spf = (string)$record->row->policy_evaluated->spf;
    #$result = readAllFromPipe("dig +nocmd -x ".$ip." +noall +answer");
    #$result = explode("\t", $result);
    if (!array_key_exists($ip, $records)) {
        $records[$ip] = array("count" => $count, "ip" => $ip);
        $records[$ip]["allpass"] = 0;
        $records[$ip]["dkimfail"] = 0;
        $records[$ip]["spffail"] = 0;
    }
    else {
        $records[$ip]["count"] += $count;
    }
    if ($result_dkim == "pass" && $result_spf == "pass") {
        $success_total += $count;
        $records[$ip]["allpass"] += $count;
    }
    if ($result_dkim != "pass") {
        $dkim_fail_total += $count;
        $records[$ip]["dkimfail"] += $count;
    }
    if ($result_spf != "pass") {
        $spf_fail_total += $count;
        $records[$ip]["spffail"] += $count;
    }
    $records[$ip]["failrate"] = round(100.0*(1.0 - (float)$records[$ip]["allpass"] / (float)$records[$ip]["count"]), 2);
    $total += $count;
}

$smarty->assign("policy", $policy);
$smarty->assign("records", $records);
$smarty->assign("total", $total);
$smarty->assign("success_total", $success_total);
$smarty->assign("dkim_fail_total", $dkim_fail_total);
$smarty->assign("spf_fail_total", $spf_fail_total);

$smarty->display("xml.tpl");

?>
    </body>
</html>
