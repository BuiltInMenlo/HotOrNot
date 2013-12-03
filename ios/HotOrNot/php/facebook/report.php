<?php session_start();

require './_db_open.php'; 

$vote_id = 0;
if (isset($_POST['hidChallengeID']) && isset($_POST['hidFBID'])) {
	$challenge_id = $_POST['hidChallengeID'];
	
	// user info
	$query = 'SELECT `id` FROM `tblUsers` WHERE `fb_id` = "'. $_POST['hidFBID'] .'";';
	$user_id = mysql_fetch_object(mysql_query($query))->id;
	
	// update the challenge status
	$query = 'UPDATE `tblChallenges` SET `status_id` = 6 WHERE `id` = '. $challenge_id .';';
	$result = mysql_query($query);
	
	// insert record to flagged challenges
	$query = 'INSERT INTO `tblFlaggedChallenges` (';
	$query .= '`challenge_id`, `user_id`, `added`) VALUES (';
	$query .= '"'. $challenge_id .'", "'. $user_id .'", NOW());';				
	$result = mysql_query($query);
	
	// send email
	$to = "bim.picchallenge@gmail.com";
	$subject = "Flagged Challenge";
	$body = "Challenge ID: #". $challenge_id ."\nFlagged By User: #". $user_id;
	$from = "picchallenge@builtinmenlo.com";
	
	$headers_arr = array();
	$headers_arr[] = "MIME-Version: 1.0";
	$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
	$headers_arr[] = "Content-Transfer-Encoding: 8bit";
	$headers_arr[] = "From: {$from}";
	$headers_arr[] = "Reply-To: {$from}";
	$headers_arr[] = "Subject: {$subject}";
	$headers_arr[] = "X-Mailer: PHP/". phpversion();

	if (mail($to, $subject, $body, implode("\r\n", $headers_arr))) 
	   $mail_res = true;

	else
	   $mail_res = false;
}

require './_db_close.php'; 
echo ("mail_res:[". $mail_res ."]<br />\n");
?>