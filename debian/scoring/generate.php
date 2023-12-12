<?php
function generateSlug($length = 8) {
    $words = ['cat', 'dog', 'bird', 'fish', 'lion', 'bear', 'deer', 'frog', 'duck', 'goat', 'cow', 'bee', 'ant', 'fox', 'owl', 'bat', 'hen',];
    $slug = '';
    $slug .= $words[rand(0, count($words) - 1)];
    $slug .= "-" . $words[rand(0, count($words) - 1)];
    $slug .= "-" . $words[rand(0, count($words) - 1)];
    $slug .= "-" . $words[rand(0, count($words) - 1)];
    return $slug;
}

$slugs = [];
for ($i = 0; $i < 30; $i++) {
    $slugs[] = generateSlug();
}
// create empty file with the filename from slug
foreach ($slugs as $slug) {
    $filename = "db/$slug";
    $file = fopen($filename, "w");
    fclose($file);
}
?>
