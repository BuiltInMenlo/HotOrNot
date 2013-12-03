<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");


if (isset($_POST['hidUserID']) && isset($_POST['hidMsg'])) {
	$query = 'SELECT `username`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $_POST['hidUserID'] .';';			
	$user_obj = mysql_fetch_object(mysql_query($query));
	
	if ($user_obj->notifications == "Y") { 			
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); //live
		//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_POST, TRUE);
		curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $user_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $_POST['hidMsg'] .'", "sound": "push_01.caf"}}');
		$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch); 
	}
	
	echo ($user_obj->username ." --> ". $_POST['hidMsg']);
}

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>