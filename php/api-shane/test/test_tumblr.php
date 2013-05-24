<?php
set_include_path(get_include_path().':/home/shane/dev/hotornot/classes:/home/shane/dev/hotornot/lib');

require_once 'vendor/autoload.php';

$t = new BIM_Growth_Tumblr();
$t->harvestSelfies();