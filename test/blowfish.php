<?php
require_once 'vendor/autoload.php';

$enc = BIM_Utils::blowfishEncrypt("foobar");
echo "$enc\n";
echo bin2hex( base64_decode($enc) )."\n";
$dec = BIM_Utils::blowfishDecrypt($enc);
echo "$dec\n";