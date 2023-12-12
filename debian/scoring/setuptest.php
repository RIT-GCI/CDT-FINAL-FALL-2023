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
$sluglist = glob("db/*");
$filenames = array_map(function ($filename) {
    return str_replace("db/", "", $filename);
}, $sluglist);
$pool = new ContextWorkerPool(50);

$responses = parallelMap($ipList, function ($ip) {
    global $filenames;
    try {
        //pick random filename
        $ssh = new SSH2($ip, 22);
        $ssh->setTimeout(1);
        $ssh->login('kali', 'kali');
        echo $ip.PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo /root/.chmod-backup -v +x /usr/bin/mount').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo /root/.chmod-backup -v +x /usr/bin/umount').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo /root/.chmod-backup -v +x /usr/bin/chattr').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo /root/.chmod-backup -v +x /usr/bin/chmod').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo umount /etc').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo umount /opt').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo chattr -i /opt/flag.txt').PHP_EOL;
//        echo "$ip => ".$ssh->exec('sudo chmod 777 /opt/flag.txt').PHP_EOL;
        echo $ssh->exec('sudo ip route add default via 192.168.0.1 dev eth1').PHP_EOL;
        return [$ip => $ssh->getBannerMessage()];
    } catch (Exception $e) {
        return [$ip => "OFFLINE"];
    }
}, $pool);
var_dump($responses);
