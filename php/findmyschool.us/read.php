<?php
	
	$link = mysql_connect($_ENV['DATABASE_SERVER'], "db4086_nexmo_usr", "x7!Usw9Z-WRe") or die("Could not connect: " . mysql_error());
	mysql_select_db("db4086_nexmo", $link) or die("Could not select database.");
	
	$i = 1;
	$file = file('sms.blob');
	foreach ($file as $line) {
		$query = 'INSERT INTO `tblTest` (';
		$query .= '`id`, `blob`, `added`) ';
		$query .= 'VALUES (NULL, "'. mysql_real_escape_string($line) .'", CURRENT_TIMESTAMP);';
		
		$result = mysql_query($query);
		$entry_id = mysql_insert_id();
		
		echo ("Successfully Added:[$entry_id]<br />");
		
		if (++$i == 3)
			break;
	}
	
	mysql_close($link);
	
	/*
	if ($_GET) {
		$file = 'sms.txt';
	
		$contents = file_get_contents($file);
		
		$line = "";
		foreach ($_GET as $key=>$val)
			$line .= "$key=$val,";
			
		$line = rtrim($line, ",");
		$line .= "\n";
		
		$contents .= $line;
		file_put_contents($file, $contents);
	}
	*/
?>