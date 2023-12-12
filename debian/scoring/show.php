<?php
// read all from db directory
$files = glob("db/*");
// create empty array
$slugs = [];
// loop through all files
foreach ($files as $file) {
    // get the filename from the path
    $filename = basename($file);
    // add the filename to the array
    $slugs[] = $filename;
}
// php score.php 2>&1 | tee -a log.txt
// forever loop
while (true){
    // clear the screen
    echo "\033[2J\033[;H";
    // show the date on the right of the console

    // get the scores from the files
    $scores = [];
    foreach ($slugs as $slug) {
        $filename = "db/$slug";
        $score = file_get_contents($filename);
        $scores[$slug] = $score;
    }
    // sort the scores
    arsort($scores);


    // print the scores in a table fit for xterm
    echo "\033[1;37m";
    echo "\033[1;34m";
    echo "Rank\tScore\tSlug\n";
    echo "\033[0m";
    $rank = 1;
    foreach ($scores as $slug => $score) {
        if ($rank > 30) {
            break; // Exit the loop after the top 30 scores
        }
        echo "\033[1;37m";
        echo "$rank\t";
        echo "\033[1;32m";
        echo "$score\t";
        echo "\033[1;33m";
        echo "$slug\n";
        $rank++;
    }
    echo "\033[0m";
    // get the last 30 letters from log.txt
    $file = fopen("log.txt", "r");
    if ($file) {
        fseek($file, -60, SEEK_END);
        $log = fread($file, 60);
        fclose($file);
    }
    echo "\033[1;37m";
    echo "\033[1;34m";
    // print log to console wrapping in a box after 30 characters
    echo "Log\n";
    echo "\033[0m";
    echo "\033[1;33m";
    echo "┌──────────────────────────────┐\n";
    echo "│";
    echo "\033[0m";
    echo "\033[1;37m";
    echo substr($log, 0, 30);
    echo "\033[1;33m";
    echo "│\n";
    echo "│";
    echo "\033[0m";
    echo "\033[1;37m";
    echo substr($log, 30, 30);
    echo "\033[1;33m";
    echo "│\n";
    echo "└──────────────────────────────┘\n";
    echo "\033[0m";

    // sleep for 1 second
    sleep(1);
}
?>
