<?php	
	if ($_GET) {
		$link = mysql_connect($_ENV['DATABASE_SERVER'], "db4086_nexmo_usr", "x7!Usw9Z-WRe") or die("Could not connect: " . mysql_error());
		mysql_select_db("db4086_nexmo", $link) or die("Could not select database.");
		
		$blob = "{";
		foreach ($_GET as $key=>$val)
			$blob .= "\"$key\":\"$val\",";
		$blob = mysql_real_escape_string(rtrim($blob, ",") ."}");
		
		$query = 'INSERT INTO `tblFindMySchool` (';
		$query .= '`id`, `blob`, `added`) ';
		$query .= 'VALUES (NULL, "'. $blob .'", CURRENT_TIMESTAMP);';
		
		$result = mysql_query($query);
		$entry_id = mysql_insert_id();
		
		mysql_close($link);
	}
?>