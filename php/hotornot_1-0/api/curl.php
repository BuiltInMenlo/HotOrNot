<?php

$d_id = $argv[1];
//'d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed';
$msg = 'TWO BUTTON TEST!';
			
$ch = curl_init();
    
curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ");
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $d_id .'"], "type":"2", "aps": {"alert": "'. $msg .'"}}');

$res = curl_exec($ch);
$err_no = curl_errno($ch);
$err_msg = curl_error($ch);
$header = curl_getinfo($ch);
curl_close($ch);

?>