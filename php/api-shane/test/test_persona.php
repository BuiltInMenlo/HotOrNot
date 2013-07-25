<?php
require_once 'vendor/autoload.php';

$p = new BIM_Growth_Persona( 'jenny1998xoxo' );

echo $p->getVolleyQuote('askfm')."\n";
echo $p->getVolleyQuote('instagram')."\n";
echo $p->getVolleyQuote('tumblr')."\n\n\n";

echo $p->getVolleyAnswer('askfm')."\n";

