<?php session_start();

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 1 OR `status_id` = 2 ORDER BY `added` DESC LIMIT 50;';
$challenge_result = mysql_query($query);

?>
	
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<script type="text/javascript" src="./jquery-1.4.2.min.js"></script>
		<script type="text/javascript">
			function sendPush(challengeID) {
				var frmPush = document.getElementById('frmPush');
					frmPush.hidChallengeID.value = challengeID;
					
					//alert (userID+"]["+msg);					
					$.post('challenge_push.php', $('#frmPush').serialize(), function(data) {
						var results_arr = data.split("|");						
						$("#divResults_" + results_arr[0]).html(results_arr[1]);
     				});
			}
			
			$(document).ready(function() {
				$("#frmChallenges").submit(function() {
					var frmChallenges = document.getElementById('frmChallenges');
					frmChallenges.hidIDs.value = frmChallenges.hidIDs.value.slice(0, -1);
					//alert (frmChallenges.hidIDs.value);   			
					$.post("challenge_push.php", $("#frmChallenges").serialize(), function(data) {
						$("#results").html(data);
	     			});
					return false;
				});
			});
			
		</script>	
		<style type="text/css" rel="stylesheet" media="screen">
			html, body {font-family:Arial, Verdana, sans-serif; font-size:12px;}
			.tdResults, #results {font-size:10; color:#ff0000;}
		</style>
	</head>
	
	<body>
		<form id="frmPush" name="frmPush">
			<input id="hidChallengeID" name="hidChallengeID" type="hidden" value="" />
		</form>
		
		<table><?php $challengeIDs = "";
		while ($challenge_obj = mysql_fetch_object($challenge_result)) {
			
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject_name = mysql_fetch_object(mysql_query($query))->title;
			
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
			$creator_name = mysql_fetch_object(mysql_query($query))->username;
			
			$local_date = date('Y-m-d H:i:s', strtotime($challenge_obj->added .' - 8 hours'));
			
			if ($challenge_obj->status_id == 1) {
				echo ("<tr><td><strong>". $creator_name ."</strong> has challenged <strong>someone</strong> to a <u>". $subject_name ."</u> challenge <em>(". $local_date .")</em></td></tr>\n");
				echo ("<tr><td><img src='". $challenge_obj->creator_img ."_l.jpg' width='128' height='128' alt='' /></td></tr>\n");
				//echo ("<tr><td><input type='button' value='Send request to next player' onclick='sendPush(". $challenge_obj->id .");' /></td></tr>\n");
				
			} else {
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				echo ("<tr><td><strong>". $creator_name ."</strong> has challenged <strong>". $challenger_name ."</strong> to a <u>". $subject_name ."</u> challenge <em>(". $local_date .")</em></td></tr>\n");
				echo ("<tr><td><img src='". $challenge_obj->creator_img ."_l.jpg' width='128' height='128' alt='' /></td></tr>\n");
				//echo ("<tr><td><input type='button' value='Send request to ". $challenger_name ."' onclick='sendPush(". $challenge_obj->id .");' /></td></tr>\n");
			}
			
			echo ("<tr><td class='tdResults'><div id='divResults_". $challenge_obj->id ."'></div></td></tr>\n");
			echo ("<tr><td><hr /></td></tr>\n");
			
			$challengeIDs .= $challenge_obj->id ."|";
		} ?></table>
		
		<form id="frmChallenges" name="frmChallenges">
			<input id="hidIDs" name="hidIDs" type="hidden" value="<?php echo($challengeIDs);?>" />
			<input type="submit" value="SEND PUSHES" />
		</form>
		
		<div id="results"></div>
	</body>
</html>

<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>