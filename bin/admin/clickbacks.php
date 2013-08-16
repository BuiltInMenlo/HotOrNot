<?php
require_once 'vendor/autoload.php';

$r = new BIM_Growth_Reports();

$clickbacks = $r->clickbacks();
echo "<pre>\n";
foreach( $clickbacks as $day => $networkData ){
    echo "$day\n";
    foreach( $networkData as $network => $counts){
        $in = $counts['inbound'];
        $out = $counts['outbound'];
        $rate = $counts['rate'];
        echo "\t$network $in/$out = $rate%\n";
    }
    echo "\n\n";
}
echo "</pre>\n";
