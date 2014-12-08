<?php
	if (count($argv) != 3 || ($argv[1] != "e" && $argv[1] != "d"))
		exit;

	$iv = base64_decode("hDfslH7tj3M=");
	$key = "KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";

	echo (($argv[1] == "e") ? base64_encode(mcrypt_encrypt(MCRYPT_BLOWFISH, $key, $argv[2], MCRYPT_MODE_CBC, $iv)) ."\n" : mcrypt_decrypt(MCRYPT_BLOWFISH, $key, base64_decode($argv[2]), MCRYPT_MODE_CBC, $iv) ."\n");
?>