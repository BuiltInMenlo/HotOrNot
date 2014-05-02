<?php
	
	$file = file('sms.blob');
	foreach($file as $line) {
		echo ("$line<br />\n");
	}
	
	
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