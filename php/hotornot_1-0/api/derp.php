<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot') or die("Could not select database.");

$query = 'SELECT `id`, `fb_id`, `username` FROM `tblUsers` WHERE `fb_id` != "";';
$result = mysql_query($query);

?>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title></title>	    
	</head>
	<body>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr><td>#</td><td width="256">FB ID:</td><td>NAME:</td></tr><?php while ($row = mysql_fetch_array($result, MYSQL_BOTH)) { 
				echo ("<tr><td>". $row['id'] ."</td><td width=\"256\">". $row['fb_id'] ."</td><td>". $row['username'] ."</td></tr>\n");
			} ?>
		</table>
	</body>
</html>

<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>