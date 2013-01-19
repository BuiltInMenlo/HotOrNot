<?php session_start();

require './_db_open.php';

if (isset($_POST['txtPhone1']) && isset($_POST['txtPhone2']) && isset($_POST['txtPhone3'])) {
	$to_phone = "+1". $_POST['txtPhone1'] . $_POST['txtPhone2'] . $_POST['txtPhone3'];
	
	$post_arr = array(
		'From' => "+12394313268",
		'To' => $to_phone,
		'Body' => "Testing Twilio API"
	);

	$ch = curl_init();    
	curl_setopt($ch, CURLOPT_URL, "https://api.twilio.com/2010-04-01/Accounts/ACb76dc4d9482a77306bc7170a47f2ea47/SMS/Messages.json");
	curl_setopt($ch, CURLOPT_USERPWD, "ACb76dc4d9482a77306bc7170a47f2ea47:00015969db460ffe0f0bd5b3df60972a");
	curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: multipart/form-data"));
	curl_setopt($ch, CURLOPT_POST, TRUE);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $post_arr);

	$res = curl_exec($ch);
	$err_no = curl_errno($ch);
	$err_msg = curl_error($ch);
	$header = curl_getinfo($ch);
	curl_close($ch);
}


require './_db_close.php';

?>