<?php
require_once 'vendor/autoload.php';

$p = new BIM_Growth_Persona( 'jenny1998xoxo' );

$p->type = 'ad';
echo $p->getVolleyQuote('instagram')."\n";
echo $p->getVolleyQuote('tumblr')."\n";
echo $p->getVolleyQuote('askfm')."\n";
echo $p->getVolleyAnswer('askfm')."\n\n";
echo $p->getAskfmSearchName()."\n";

print_r( $p->getTags('instagram'));
print_r($p->getTags('tumblr'));
print_r($p->getTags('askfm'));
print_r($p->getTags('askfm'));

$p->type = 'authentic';
echo $p->getVolleyQuote('instagram')."\n";
echo $p->getVolleyQuote('tumblr')."\n";
echo $p->getVolleyQuote('askfm')."\n";
echo $p->getVolleyAnswer('askfm')."\n\n\n";
echo $p->getAskfmSearchName()."\n";

print_r( $p->getTags('instagram'));
print_r($p->getTags('tumblr'));
print_r($p->getTags('askfm'));
print_r($p->getTags('askfm'));

$p->type = 'other';
echo $p->getVolleyQuote('instagram')."\n";
echo $p->getVolleyQuote('tumblr')."\n";
echo $p->getVolleyQuote('askfm')."\n";
echo $p->getVolleyAnswer('askfm')."\n\n\n";
echo $p->getAskfmSearchName()."\n";
print_r( $p->getTags('instagram'));
print_r($p->getTags('tumblr'));
print_r($p->getTags('askfm'));
print_r($p->getTags('askfm'));
