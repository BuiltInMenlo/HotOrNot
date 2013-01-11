<?php

$db_conn = mysql_connect('localhost', 'picchat_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('picchat') or die("Could not select database.");


echo ("<html><head><meta charset=\"utf-8\"></head><body><center><h2>PicChat Users</h2></center><table>\n");

$fb_arr = array();
$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `fb_id` != "";';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {	
	array_push($fb_arr, $row['fb_id']);
	echo ("<tr>");
	echo ("<td><a href='https://www.facebook.com/profile.php?id={$row['fb_id']}' target='_blank'><img src='https://graph.facebook.com/{$row['fb_id']}/picture?type=square' width='50' height='50' alt='{$row['fb_id']}' border='0' /></a></td>");
	echo ("<td><a href='https://www.facebook.com/messages/{$row['fb_id']}' target='_blank'>{$row['username']}</a></td>");
	echo ("<td>{$row['fb_id']}</td></tr>\n");
}			
echo ("</table></body></html>");
			
if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>