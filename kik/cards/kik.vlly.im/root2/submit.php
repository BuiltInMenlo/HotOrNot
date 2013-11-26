<?php

$db_conn = mysql_connect('internal-db.s4086.gridserver.com', 'db4086_sc_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('db4086_kik_selfieclub') or die("Could not select database.");

if (isset($_POST['txtEmail']) && isset($_POST['txtUsername'])) {
	$query = 'SELECT `id` FROM `tblSignups` WHERE `username` = "'. $_POST['txtUsername'] .'";';
	
	if (mysql_num_rows(mysql_query($query)) == 0) { 
		$query = 'INSERT INTO `tblSignups` (';
		$query .= '`id`, `email`, `username`, `added`) VALUES (';
		$query .= 'NULL, "'. $_POST['txtEmail'] .'", "'. $_POST['txtUsername'] .'", NOW());';
		$result = mysql_query($query);
		$signup_id = mysql_insert_id();
	}
}

/*
$url_arr = explode('/', $_SERVER['REQUEST_URI']);

$url = "http://". $_SERVER['SERVER_NAME'] . "/";
for ($i=1; $i<count($url_arr)-1; $i++)
	$url .= $url_arr[$i] . "/";
$url .= "thankyou.html";

header('Location: '. $url);
*/