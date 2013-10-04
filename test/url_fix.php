<?php
// $url = "https://hotornot-avatars.s3.amazonaws.com/https://hotornot-avatars.s3.amazonaws.com/https://hotornot-avatars.s3.amazonaws.com/https://hotornot-avatars.s3.amazonaws.com/https://hotornot-avatars.s3.amazonaws.com/67fd6d976e73b11836ea1710376129f1de5cbf7465e472130ef5ab8dc333f88b-1380324946Large_640x1136.jpgLarge_640x1136.jpgLarge_640x1136.jpgLarge_640x1136.jpgLarge_640x1136.jpg";
//$url = "https://d3j8du2hyvd35p.cloudfront.net/https://d3j8du2hyvd35p.cloudfront.net/a63293acfdfcd75a2b06e04b85723c1a7957d46ceb0f3ce8332148e7caa26164-1380297951Large_640x1136.jpgLarge_640x1136.jpg";
//if( preg_match('@^http.*?http@', $url ) ){
//      $url = preg_replace( '@^(?:https*://.*?)+(https*://.+?\.jpg).+?\.jpg$@', '$1', $url );
//}
//print_r( $url."\n" );

$regex = '/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i';
$str = "kjhgkjghkkggk&
shane@shanehill.com 
fgfgfgfg";

$matches = array();
preg_match($regex,$str,$matches);
print_r( $matches );