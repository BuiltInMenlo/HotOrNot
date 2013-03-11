<?php

$db_conn = mysql_connect('internal-db.s4086.gridserver.com', 'db4086_kodee_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('db4086_kodee_signup') or die("Could not select database.");

if (isset($_POST['phone_email'])) {
	$query = 'SELECT `id` FROM `tblSignups` WHERE `entry` = "'. $_POST['phone_email'] .'";';
	
	if (mysql_num_rows(mysql_query($query)) == 0) { 
		$query = 'INSERT INTO `tblSignups` (';
		$query .= '`id`, `entry`, `added`) VALUES (';
		$query .= 'NULL, "'. $_POST['phone_email'] .'", NOW());';
		$result = mysql_query($query);
		$signup_id = mysql_insert_id();
	}
}

header('Location: http://www.kodee.me/?result=1');
