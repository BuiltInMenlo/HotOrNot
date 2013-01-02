<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot') or die("Could not select database.");


$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = 3;';			
$creator_obj = mysql_fetch_object(mysql_query($query));
$device_token = $creator_obj->device_token;
$isPush = ($creator_obj->notifications == "Y");

echo ("isPush[".$isPush."] (".$device_token.")\n");

//if ($isPush == true) { 			
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
	curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ");
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "DERP has accepted your #lame challenge!", "sound": "push_01.caf"}}');
 	$res = curl_exec($ch);
	$err_no = curl_errno($ch);
	$err_msg = curl_error($ch);
	$header = curl_getinfo($ch);
	curl_close($ch); 
//}


if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>