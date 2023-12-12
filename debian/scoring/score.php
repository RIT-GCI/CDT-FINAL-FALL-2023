<?php
require "vendor/autoload.php";
use phpseclib3\Net\SSH2;

use Amp\Parallel\Worker\ContextWorkerPool;
use function Amp\ParallelFunctions\parallelMap;
define('NET_SSH2_LOGGING', SSH2::LOG_COMPLEX);

$ipList = [];
for ($y = 1; $y <= 10; $y++) {
    for ($x = 10; $x <= 14; $x++) {
        $ipList[] = "192.168.$y.$x";
    }
}
$pool = new ContextWorkerPool(50);

//read a list of filenames from db/ directory and cleaning the db/ off it
//loop every 10 seconds based off wall clock
$lasttime = time();
while (true){
    //check if 10 seconds has passed
    if (time() - $lasttime >= 60){
        $lasttime = time();
    }else{
        sleep(1);
        echo "s";
        continue;
    }

    $filenames = array_map(function ($filename) {
        return str_replace("db/", "", $filename);
    }, glob("db/*"));
    $responses = parallelMap($ipList, function ($ip) {
        try {
            $ssh = new SSH2($ip, 22);
            $ssh->setTimeout(1);
            $ssh->login('scoring', '1234');
            echo ".";
            return [$ip => $ssh->getBannerMessage()];
        } catch (Exception $e) {
            return [$ip => "OFFLINE"];
        }
    }, $pool);
    $offline = [];
    //check all responses for the flag, the flag being $filename, open the file and increment the score by 3
    foreach ($responses as $response) {
        foreach ($response as $ip => $banner) {
            foreach ($filenames as $filename) {
                if (strpos($banner, $filename) !== false) {
                    $score = file_get_contents("db/$filename");
                    // check if score is not a int, if it is not a int set it to 0
                    if (!is_numeric($score)) {
                        $score = 0;
                    }
                    $score += 3;
                    file_put_contents("db/$filename", $score);
                    echo "+";
                }
                // if the banner contains OFFLINE add it to the $offline array
                if (strpos($banner, "OFFLINE") !== false) {
                    $offline[] = $ip;
                    echo "!";
                    break;
                }
            }
        }
    }
    //write the $offline array to offline.txt
    file_put_contents("offline.txt", json_encode($offline));

}