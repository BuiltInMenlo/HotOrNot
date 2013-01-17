<?php

require './_db_open.php'; 

if (isset($_POST['hidFBID']) && isset($_POST['hidUsername']) && isset($_POST['hidGender'])) {
	$query = 'SELECT `id` FROM `tblUsers` WHERE `fb_id` = "'. $_POST['hidFBID'] .'";';
	
	if (mysql_num_rows(mysql_query($query)) == 0) {
		$query = 'INSERT INTO `tblUsers` (';
		$query .= '`id`, `username`, `device_token`, `fb_id`, `gender`, `paid`, `points`, `notifications`, `last_login`, `added`) ';
		$query .= 'VALUES (NULL, "'. $_POST['hidUsername'] .'", "", "'. $_POST['hidFBID'] .'", "'. $_POST['hidGender'] .'", "N", "0", "Y", CURRENT_TIMESTAMP, NOW());';
		$result = mysql_query($query);
		$user_id = mysql_insert_id();
		
		$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $_POST['hidFBID'] .'";';
		if (mysql_num_rows(mysql_query($query)) > 0) {
			$invite_id = mysql_fetch_object(mysql_query($query))->id;
			
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 7 AND `challenger_id` = '. $invite_id .';';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'UPDATE `tblChallenges` SET `status_id` = 2, `challenger_id` = "'. $user_id .'" WHERE `id` = '. $challenge_row['id'] .';';
				$result = mysql_query($query);
			}
		}
	
	} else {
		$query = 'UPDATE `tblUsers` SET `username` = "'. $_POST['hidUsername'] .'", `gender` = "'. $_POST['hidGender'] .'", `last_login` = CURRENT_TIMESTAMP WHERE `fb_id` = '. $_POST['hidFBID'] .';';
		$result = mysql_query($query);
		
		$query = 'SELECT `id` FROM `tblUsers` WHERE `fb_id` = "'. $_POST['hidFBID'] .'";';
		$result = mysql_query($query);
		$user_id = mysql_fetch_object($result)->id;
	}
}

print ("hidFBID:[". $_POST['hidFBID'] ."]\n");
print ("hidUsername:[". $_POST['hidUsername'] ."]\n");
print ("hidGender:[". $_POST['hidGender'] ."]\n");
print ("userID:[". $user_id ."]\n");


require './_db_close.php'; 

?>