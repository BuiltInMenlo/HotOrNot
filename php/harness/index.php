<?php

$db_conn = mysql_connect('localhost', 'root', '') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");


$first_date = date('Y-m-d H:i:s', strtotime('2013-11-26 00:00:00'));


function dailyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	
	for ($i=0; $i<7; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));
		$userID_arr = array();
		
		$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$signup_tot = mysql_num_rows(mysql_query($query));
		
		/*
		$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'" AND `last_login` > "'. $start_date .'" AND `last_login` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result))
			$userID_arr[$obj->id] = true;
		*/
		
		/*
		$query = 'SELECT `creator_id` FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			if ($obj->creator_id != 0)
				$userID_arr[$obj->creator_id] = true;
		}
		*/
		
		
		$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		$vote_tot = mysql_num_rows($result);
		while ($obj = mysql_fetch_object($result))
			$userID_arr[$obj->user_id] = true;
		
		
		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ."</td><td align=\"right\">". count($userID_arr) ." / ". $signup_tot ." = ". number_format((count($userID_arr) / $signup_tot) * 100, 2) ."% (". $vote_tot .")</td></tr>");
		$start_date = $end_date;
	}
}

function weeklyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	
	for ($i=0; $i<4; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 6 days'));
		$userID_arr = array();
		
		$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$signup_tot = mysql_num_rows(mysql_query($query));
			
		/*
		$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'" AND `last_login` > "'. $start_date .'" AND `last_login` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result))
			$userID_arr[$obj->id] = true;
		*/
		
		/*
		$query = 'SELECT `creator_id` FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			if ($obj->creator_id != 0)
				$userID_arr[$obj->creator_id] = true;
		}
		*/
		
		
		$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		$vote_tot = mysql_num_rows($result);
		while ($obj = mysql_fetch_object($result))
			$userID_arr[$obj->user_id] = true;
		
		
		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ." / ". date('m-d-Y', strtotime($end_date)) ."</td><td align=\"right\">". count($userID_arr) ." / ". $signup_tot ." = ". number_format((count($userID_arr) / $signup_tot) * 100, 2) ."% (". $vote_tot .")</td></tr>");
		//$start_date = $end_date;
		$start_date = date('Y-m-d H:i:s', strtotime($end_date .' + 1 day'));
	}
}

function monthlyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 30 days'));
	$userID_arr = array();
	
	$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$signup_tot = mysql_num_rows(mysql_query($query));
		
	/*
	$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'" AND `last_login` > "'. $start_date .'" AND `last_login` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result))
		$userID_arr[$obj->id] = true;
	*/
	
	/*
	$query = 'SELECT `creator_id` FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		if ($obj->creator_id != 0)
			$userID_arr[$obj->creator_id] = true;
	}
	*/
	
	
	$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	$vote_tot = mysql_num_rows($result);
	while ($obj = mysql_fetch_object($result)) {
		$userID_arr[$obj->user_id] = true;
	}
	
	
	echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ." / ". date('m-d-Y', strtotime($end_date)) ."</td><td align=\"right\">". count($userID_arr) ." / ". $signup_tot ." = ". number_format((count($userID_arr) / $signup_tot) * 100, 2) ."% (". $vote_tot .")</td></tr>");
}

?>

<html lang="en">
	<head>
		<meta charset="utf-8" />		
		<style type="text/css" rel="stylesheet" media="screen">
			html, body {font-family:Arial, Verdana, sans-serif; font-size:12px;}
			.tdHeader {font-weight:bold;}
		</style>
	</head>
	
<body>
	<a name="top" />
	<h3><a href="#daily_active_users">Daily Active Users</a></h3>
	<h3><a href="#weekly_active_users">Weekly Active Users</a></h3>
	<h3><a href="#monthly_active_users">Monthly Active Users</a></h3>
	<hr /><hr />

	<a name="daily_active_users" /><a href="#top">TOP</a><table>
		<tr><td width="100%" colspan="2" align="center">DAUs</td></tr>
		<tr><td width="100" align="center">DATE</td><td align="center">TOTALS</td></tr>
			<?php dailyActiveUsers('2013-11-26 00:00:00'); ?>
		</tr>
	</table><hr />

	<a name="weekly_active_users" /><a href="#top">TOP</a><table>
		<tr><td width="100%" colspan="2" align="center">WAUs</td></tr>
		<tr><td width="100" align="center">DATE</td><td align="center">TOTALS</td></tr>
			<?php weeklyActiveUsers('2013-11-27 00:00:00'); ?>
	</table><hr />

	<a name="monthly_active_users" /><a href="#top">TOP</a><table>
		<tr><td width="100%" colspan="2" align="center">MAUs</td></tr>
		<tr><td width="100" align="center">DATE</td><td align="center">TOTALS</td></tr>
			<?php monthlyActiveUsers('2013-12-04 00:00:00'); //monthlyActiveUsers('2013-11-26 00:00:00'); ?>
			<?php monthlyActiveUsers('2014-01-02 00:00:00'); //monthlyActiveUsers('2013-12-26 00:00:00'); ?>
	</table>
	
	<hr/>
<?php

$userID_arr = array();
$start_date = date('Y-m-d H:i:s', strtotime('2013-11-26 00:00:00'));
$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));

$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
$result = mysql_query($query);
while ($user_obj = mysql_fetch_object($result)) {
	$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `user_id` = '. $user_obj->id .' AND `added` > "'. $start_date .'" AND `added` < "'. date('Y-m-d H:i:s', strtotime($start_date .' + 7 days')) .'";';
	$res = mysql_query($query);
	while ($obj = mysql_fetch_object($res)) {
		$userID_arr[$user_obj->id] = true;
	}
}

echo ("Day 1 users active over following 6 days: ". count($userID_arr) ." / ". mysql_num_rows($result) ." = (". number_format((count($userID_arr) / mysql_num_rows($result)) * 100, 2) ."%)<br />");

$userID_arr = array();
$start_date = date('Y-m-d H:i:s', strtotime('2013-11-26 00:00:00'));
$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));

$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
$result = mysql_query($query);
while ($user_obj = mysql_fetch_object($result)) {
	$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `user_id` = '. $user_obj->id .' AND `added` > "'. date('Y-m-d H:i:s', strtotime($start_date .' + 7 days')) .'" AND `added` < "'. date('Y-m-d H:i:s', strtotime($start_date .' + 8 days')) .'";';
	$res = mysql_query($query);
	while ($obj = mysql_fetch_object($res)) {
		$userID_arr[$user_obj->id] = true;
	}
}

echo ("Day 1 users active on day 7: ". count($userID_arr) ." / ". mysql_num_rows($result) ." = (". number_format((count($userID_arr) / mysql_num_rows($result)) * 100, 2) ."%)<hr />");




$userID_arr = array();
$start_date = date('Y-m-d H:i:s', strtotime('2013-11-26 00:00:00'));
$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
$result = mysql_query($query);
while ($user_obj = mysql_fetch_object($result)) {
	$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `user_id` = '. $user_obj->id .' AND `added` > "'. $start_date .'" AND `added` < "'. date('Y-m-d H:i:s', strtotime($start_date .' + 28 days')) .'";';
	$res = mysql_query($query);
	while ($obj = mysql_fetch_object($res)) {
		$userID_arr[$user_obj->id] = true;
	}
}

echo ("Day 1 users active over following 27 days: ". count($userID_arr) ." / ". mysql_num_rows($result) ." = (". number_format((count($userID_arr) / mysql_num_rows($result)) * 100, 2) ."%)<br />");

$userID_arr = array();
$start_date = date('Y-m-d H:i:s', strtotime('2013-11-26 00:00:00'));
$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
$result = mysql_query($query);
while ($user_obj = mysql_fetch_object($result)) {
	$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `user_id` = '. $user_obj->id .' AND `added` > "'. date('Y-m-d H:i:s', strtotime($start_date .' + 28 days')) .'" AND `added` < "'. date('Y-m-d H:i:s', strtotime($start_date .' + 29 days')) .'";';
	$res = mysql_query($query);
	while ($obj = mysql_fetch_object($res)) {
		$userID_arr[$user_obj->id] = true;
	}
}

echo ("Day 1 users active on day 28: ". count($userID_arr) ." / ". mysql_num_rows($result) ." = (". number_format((count($userID_arr) / mysql_num_rows($result)) * 100, 2) ."%)<hr />");

?>

</body>
</html>


<?php
if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>