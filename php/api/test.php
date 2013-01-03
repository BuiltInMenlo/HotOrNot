<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

/* //SEND PUSH
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
*/



/* //MOVE CHALLENGER IMAGES & PARTICIPANTS INTO CHALLENGES TABLE
$query = 'SELECT `id` FROM `tblChallenges`;';
$challenge_result = mysql_query($query);
while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
	$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
	$participant_result = mysql_query($query);
	
	$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
	$img_result = mysql_query($query);
	
	$participant_id = (mysql_num_rows($participant_result) > 0) ? mysql_fetch_object($participant_result)->user_id : 0;
	$img_url = (mysql_num_rows($img_result) > 0) ? mysql_fetch_object($img_result)->url : "";
	
	$query = 'UPDATE `tblChallenges` SET `challenger_id` = "'. $participant_id .'", `challenger_img` = "'. $img_url .'" WHERE `id` = '. $challenge_row['id'] .';';
	$result = mysql_query($query);
}
*/


/* REMOVE DUPLICATE VOTES ON CHALLENGE FROM SAME USER
$prev_arr = array('challenge_id' => 0, 'user_id' => 0);
$curr_arr = array('challenge_id' => 0, 'user_id' => 0);


$cnt = 0;
$id_arr = array();
$query = 'SELECT * FROM `tblChallengeVotes` ORDER BY `challenge_id`, `user_id`;';
$vote_result = mysql_query($query);
while ($vote_row = mysql_fetch_array($vote_result, MYSQL_BOTH)) {
	$prev_arr = $curr_arr;
	$curr_arr = array('challenge_id' => $vote_row['challenge_id'], 'user_id' => $vote_row['user_id']);
	
	if ($prev_arr['challenge_id'] == $curr_arr['challenge_id'] && $prev_arr['user_id'] == $curr_arr['user_id'])
		array_push($id_arr, $vote_row['id']);
}

foreach ($id_arr as $key) {
	echo ("REMOVE[". $key ."]\n");
	
	$query = 'DELETE FROM `tblChallengeVotes` WHERE `id` = '. $key .';';
	$result = mysql_query($query);
}
*/


/* //PREPEND # TO SUBJECTS
$query = 'SELECT * FROM `tblChallengeSubjects`;';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {	
	$query = 'UPDATE `tblChallengeSubjects` SET `title` = "'. "#" . $row['title'] .'" WHERE `id` = '. $row['id'] .';';
	$res = mysql_query($query);
}
*/


 //SEND EMAIL W/ HEADERS
$msg = "Lorem ipsum sit dolar amet!";
$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = 2;';
$username = mysql_fetch_object(mysql_query($query))->username;


$to = "Matt Holcombe <matt.holcombe@gmail.com>, ". $username ." <". $username ."@facebook.com>";
$subject = "Welcome to PicChallengeMe!";
$from = "PicChallenge <picchallenge@builtinmenlo.com>";

$headers_arr = array();
$headers_arr[] = "MIME-Version: 1.0";
$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
$headers_arr[] = "Content-Transfer-Encoding: 8bit";
$headers_arr[] = "From: {$from}";
$headers_arr[] = "Reply-To: {$from}";
$headers_arr[] = "Subject: {$subject}";
$headers_arr[] = "X-Mailer: PHP/". phpversion();

echo (mail($to, $subject, $msg, implode("\r\n", $headers_arr)) ."\n");
			
			
if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>