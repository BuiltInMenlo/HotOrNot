<?php
$url = "https://d3j8du2hyvd35p.cloudfront.net/https://d3j8du2hyvd35p.cloudfront.net/a63293acfdfcd75a2b06e04b85723c1a7957d46ceb0f3ce8332148e7caa26164-1380297951Large_640x1136.jpgLarge_640x1136.jpg";
if( preg_match('@^http.*?http@', $url ) ){
    $url = preg_replace( '@^https*://.*?(https*://.+?\.jpg).+?\.jpg$@', '$1', $url );
}
print_r( $url."\n" );
