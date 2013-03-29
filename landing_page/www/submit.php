<?php

$db_conn = mysql_connect('internal-db.s4086.gridserver.com', 'db4086_kodee_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('db4086_kodee_signup') or die("Could not select database.");

//echo ($_POST['hidFriends'] ."<br />");
if ($_POST['hidFriends'] == "1") {
	for ($i=1; $i<=3; $i++) {
		//echo ($i ."] ". $_POST['txtFriend'. $i] ."<br />");
		
		$query = 'SELECT `id` FROM `tblVolleySignups` WHERE `entry` = "'. $_POST['txtFriend'. $i] .'";';
		if (mysql_num_rows(mysql_query($query)) == 0) { 
			$query = 'INSERT INTO `tblVolleySignups` (';
			$query .= '`id`, `entry`, `added`) VALUES (';
			$query .= 'NULL, "'. $_POST['txtFriend'. $i] .'", NOW());';
			$result = mysql_query($query);
			$signup_id = mysql_insert_id();
	
		} else
			$signup_id = 0;
	}
	
	$redirect_url = './thankyouFriends.php?result='. $signup_id;

} else {
	if (isset($_POST['phone_email'])) {
		$query = 'SELECT `id` FROM `tblVolleySignups` WHERE `entry` = "'. $_POST['phone_email'] .'";';
	
		if (mysql_num_rows(mysql_query($query)) == 0) { 
			$query = 'INSERT INTO `tblVolleySignups` (';
			$query .= '`id`, `entry`, `added`) VALUES (';
			$query .= 'NULL, "'. $_POST['phone_email'] .'", NOW());';
			$result = mysql_query($query);
			$signup_id = mysql_insert_id();
	
		} else
			$signup_id = 0;
	}
	
	$redirect_url = './thankyou.php?result='. $signup_id;
}

header('Location: '. $redirect_url);
