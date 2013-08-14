<html>
<head>
{include file="header.tpl"}
    <title>XML分析结果</title>
<style type="text/css">
table.gridtable {
    font-family: verdana,arial,sans-serif;
    font-size:11px;
    color:#333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
}
table.gridtable th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
}
table.gridtable td {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
}
</style>

</head>
<body>
    <div style="float:left;width:100%">
    <table class="gridtable" style="float:left">
        <tbody>
            <th>META信息</th>
            <tr><td>org name:</td><td>{$meta["org_name"]}</td></tr>
            <tr><td>email:</td><td>{$meta["email"]}</td></tr>
            <tr><td>extra info:</td><td>{$meta["extra_info"]}</td></tr>
            <tr><td>report_id:</td><td>{$meta["report_id"]}</td></tr>
            <tr><td>date:</td><td>{$meta["date"]}</td></tr>
       </tbody>
    </table>
    <table class="gridtable" style="float:left;margin-left:50px">
        <tbody>
            <th>Policy信息</th>
            <tr><td>domain:</td><td>{$policy["domain"]}</td></tr>
            <tr><td>policy:</td><td>{$policy["policy"]}</td></tr>
            <tr><td>dkim:</td><td>{$policy["dkim"]}</td></tr>
            <tr><td>spf:</td><td>{$policy["spf"]}</td></tr>
            <tr><td>percentage:</td><td>{$policy["percentage"]}</td></tr>
       </tbody>
    </table>
    <table class="gridtable" style="float:left;margin-left:50px">
        <tbody>
            <th>汇总信息</th>
            <tr><td>total:</td><td>{$total}</td></tr>
            <tr><td>success:</td><td>{$success_total}</td></tr>
            <tr><td>dkim failed:</td><td>{$dkim_fail_total}</td></tr>
            <tr><td>spf failed:</td><td>{$spf_fail_total}</td></tr>
        </tbody>
    </table>
    </div>
<hr>
    <table class="gridtable">
        <thead>
            <tr>
                <th>ip</th><th>count</th>
                <th>success</th><th>dkim failed</th>
                <th>spf failed</th><th>failure rate</th>
            </tr>
        </thead>
        <tbody>
            {foreach name=ip item=record from=$records}
<tr>
<td>{$record["ip"]}</td><td>{$record["count"]}</td>
<td>{$record["allpass"]}</td><td>{$record["dkimfail"]}</td>
<td>{$record["spffail"]}</td><td>{$record["failrate"]}%</td>
</tr>
            {/foreach}
        </tbody>
<body>
</html>
