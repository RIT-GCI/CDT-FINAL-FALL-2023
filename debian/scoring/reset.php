<?php
// write a 0 to every file in the db directory
$files = glob("db/*");
foreach ($files as $file) {
    file_put_contents($file, "0");
}
