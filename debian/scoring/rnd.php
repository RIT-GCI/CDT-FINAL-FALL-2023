<?php
// write random scores between 1 and 1 million to every file in the db directory
$files = glob("db/*");
foreach ($files as $file) {
    file_put_contents($file, rand(1, 10));
}
?>
