<?php

$files = glob("rustdesk/*");

$serverlist = json_decode(`openstack server list --long -f json`, TRUE);
$netmap = array();
foreach($serverlist as $server){
$netmap[$server["Networks"]["SSHJumpNet"][0]] = $server["Networks"]["cdt-final"][0];
}
foreach($files as $file){

$fileexplode = explode("/", $file);
$json = json_decode(file_get_contents($file), TRUE);
$ip = explode(".", $netmap[$fileexplode[1]] );
echo $netmap[$fileexplode[1]] . " " . $fileexplode[1] . " " . $json["id"] . " " . $json["pw"]. " " . $ip[2] . PHP_EOL; 
}

