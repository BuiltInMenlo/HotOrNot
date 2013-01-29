<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");


// TOP SCORE
$now_date = date('Y-m-d H:i:s', time());					
$start_date = date('Y-m-d H:i:s', strtotime($now_date .' - 7 days'));

$query = 'SELECT `creator_id`, `challenger_id` FROM `tblChallenges` WHERE `added` > "'. $start_date .'";';
$result = mysql_query($query);

// prime creator & challenger for challenges this week
$user_arr = array();
$vote_arr = array();
$poke_arr = array();
$total_arr = array();
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$user_arr[$row['creator_id']] = 0;
	$user_arr[$row['challenger_id']] = 0;
	$vote_arr[$row['creator_id']] = 0;
	$vote_arr[$row['challenger_id']] = 0;
	$total_arr[$row['creator_id']] = 0;
	$total_arr[$row['challenger_id']] = 0;
	$poke_arr[$row['creator_id']] = 0;
	$poke_arr[$row['challenger_id']] = 0;
}

$query = 'SELECT `user_id` FROM `tblUserPokes` WHERE `added` > "'. $start_date .'";';
$result = mysql_query($query);

// prime pokes for challenges this week
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$poke_arr[$row['user_id']] = 0;
	$user_arr[$row['user_id']] = 0;
	$vote_arr[$row['user_id']] = 0;
	$total_arr[$row['user_id']] = 0;
}

// increment pokes
$query = 'SELECT `user_id` FROM `tblUserPokes` WHERE `added` > "'. $start_date .'";';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$poke_arr[$row['user_id']]++;
}


$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'";';
$challenge_result = mysql_query($query);

// challenges this week
while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
	$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .';';
	$vote_result = mysql_query($query);
	
	// calc votes
	while ($vote_row = mysql_fetch_array($vote_result, MYSQL_BOTH)) {
		$vote_arr[$vote_row['challenger_id']]++;
	}
	
	// increment for creator
	$user_arr[$challenge_row['creator_id']]++;
	
	$total_arr[$challenge_row['creator_id']] = 0;
	$total_arr[$challenge_row['challenger_id']] = 0;
}


foreach ($user_arr as $key => $val) {
	$total_arr[$key] = $val + ($vote_arr[$key] * 5) + ($poke_arr[$key] * 10);
}

arsort($total_arr);

?>

<html lang="en">
	<head>
		<meta charset="utf-8" />
		<script type="text/javascript" src="./jquery-1.4.2.min.js"></script>
		<script type="text/javascript">
			function sendPush(userID, msg) {
				var frmSubmit = document.getElementById('frmSubmit');
					frmSubmit.hidUserID.value = userID;
					frmSubmit.hidMsg.value = msg;
					
					//alert (userID+"]["+msg);					
					$.post('week_push.php', $('#frmSubmit').serialize(), function(data) {
						$("#results").html(data);
     				});
			}
		</script>
		
		<style type="text/css" rel="stylesheet" media="screen">
			html, body {font-family:Arial, Verdana, sans-serif; font-size:12px;}
			.tdHeader {font-weight:bold;}
		</style>
	</head>
	
	<body>
		<form id="frmSubmit" name="frmSubmit">
			<input id="hidUserID" name="hidUserID" type="hidden" value="" />
			<input id="hidMsg" name="hidMsg" type="hidden" value="" />
		</form>
		
		<h2>Top Winners for <?php echo ($start_date); ?> thru <?php echo ($now_date); ?></h2>
		<hr width="90%" />
		
		<div id="results">CLICK PUSH TO SEND NOTIFICATION… "You have placed XX this week!"</div>
		<hr width="90%" />
		
		<table><tr><td class="tdHeader">#</td><td class="tdHeader">USERNAME</td><td class="tdHeader">CHALLENGES</td><td class="tdHeader">VOTES</td><td class="tdHeader">POKES</td><td class="tdHeader">TOTAL</td><td class="tdHeader">SEND</td></tr>
		<?php $ind = 1;
		foreach ($total_arr as $key => $val) {
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $key .';';
			$username = mysql_fetch_object(mysql_query($query))->username;
			
			$msg = "You have placed {$ind}";			
			if ($ind % 10 == 1)
				$msg .= "st this week!";
						
			else if ($ind % 10 == 2)
				$msg .= "nd this week!";
							
			else if ($ind % 10 == 3)
				$msg .= "rd this week!";
							
			else
				$msg .= "th this week!";
	
			echo ("\t\t<tr><td>". $ind ."</td>");
			echo ("<td>". $username ."</td>");
			echo ("<td>". $user_arr[$key] ."</td>");
			echo ("<td>". $vote_arr[$key] ."</td>");
			echo ("<td>". $poke_arr[$key] ."</td>");
			echo ("<td>". $val ."</td>");
			//echo ("<td><input type='button' onclick='sendPush(". $key .", \"". $msg ."\")' value='PUSH' /></td></tr>\n");
			echo ("<td></td></tr>\n");
			
			$ind++;
		} ?>
	</table></body>
</html>

<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>