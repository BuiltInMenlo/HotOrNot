<?php

$db_conn = mysql_connect('internal-db.s4086.gridserver.com', 'db4086_kodee_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('db4086_kodee_signup') or die("Could not select database.");

$query = 'SELECT `entry` FROM `tblVolleySignups`;';
$result = mysql_query($query);

while ($row = mysql_fetch_assoc($result)) {
	if (is_numeric($row['entry']))
		echo ($row['entry'] .",");
}


if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>