<?php
require_once 'vendor/autoload.php';

$p = new BIM_Growth_Persona( 'jenny1998xoxo' );
echo $p->getTrackingUrl('askfm')."\n";
echo $p->getTrackingUrl('instagram')."\n";
echo $p->getTrackingUrl('tumblr')."\n";

