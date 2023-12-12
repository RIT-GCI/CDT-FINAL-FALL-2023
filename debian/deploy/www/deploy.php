<?php
if(!empty($_GET["id"])){
file_put_contents("../rustdesk/".$_SERVER["REMOTE_ADDR"], json_encode($_GET));
}

if(!empty($_GET["state"])){
    file_put_contents("../state/".$_SERVER["REMOTE_ADDR"], time());
}