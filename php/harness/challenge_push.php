<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

function removeElement($arr, $element) {
	$ind = 0;
	foreach ($arr as $key => $val) {
		if ($val == $element) {
			array_splice($arr, $ind, 1);
			break;
		}
		$ind++;
	}
	
	return ($arr);
}

if (isset($_POST['hidIDs'])) {
	$challengeID_arr = explode('|', $_POST['hidIDs']);
	
	foreach ($challengeID_arr as $key => $val) {

//if (isset($_POST['hidChallengeID'])) {
	//$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $_POST['hidChallengeID'] .';';
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $val .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
	$subject_name = mysql_fetch_object(mysql_query($query))->title;
	
	$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';			
	$creator_obj = mysql_fetch_object(mysql_query($query));
	
	if ($challenge_obj->status_id == 1) {
		$query = 'SELECT * FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj->subject_id .' AND `creator_id` != '. $challenge_obj->creator_id .' ORDER BY `added` DESC LIMIT 1;';			
		$result = mysql_query($query);
		
		if (mysql_num_rows($result) > 0) {
			$challenger_id = mysql_fetch_object($result)->creator_id;
		
		} else {
			$user_arr = array();
			$query = 'SELECT `creator_id`, `challenger_id` FROM `tblChallenges` WHERE `status_id` = 4;';
			$result = mysql_query($query);
			
			while ($obj = mysql_fetch_object($result)) {
				array_push($user_arr, $obj->creator_id);
				array_push($user_arr, $obj->challenger_id);
			}
			
			$challenger_id = $user_arr[mt_rand(0, count($user_arr) - 1)];
		}
	
	} else {
		$challenger_id = $challenge_obj->challenger_id;
	}
	
	$query = 'SELECT `username`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
	$challenger_obj = mysql_fetch_object(mysql_query($query));
	
	// if ($challenger_obj->notifications == "Y") {
	// 	$ch = curl_init();
	// 	curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
	// 	curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); //live
	// 	//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
	// 	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
	// 	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
	// 	curl_setopt($ch, CURLOPT_POST, TRUE);
	// 	curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"1", "aps": {"alert": "YOUR NEXT! '. $creator_obj->username .' has challenged you to '. $subject_name .'", "sound": "push_01.caf"}}');
	// 	$res = curl_exec($ch);
	// 	$err_no = curl_errno($ch);
	// 	$err_msg = curl_error($ch);
	// 	$header = curl_getinfo($ch);
	// 	curl_close($ch);
	// }
	
	//echo ($challenge_obj->id ."|*Push sent to ". $challenger_obj->username ."");
	echo ("*Push sent to ". $challenger_obj->username ."<br />");
}
}

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>