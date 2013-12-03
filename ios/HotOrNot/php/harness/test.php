<!DOCTYPE html>
<html lang="en"><head><meta charset='utf-8'></head><body>


<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

function userForChallenge($user_id, $challenge_id) {	
	// prime the user
	$user_arr = array(
		'id' => $user_id, 
		'fb_id' => "",
		'username' => "",
		'avatar' => "",
		'img' => "",
		'score' => 0				
	);
	
	// challenge object
	$query = 'SELECT `status_id`, `creator_id`, `challenger_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	// user is the creator
	if ($user_id == $challenge_obj->creator_id) {
		$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_arr['img'] = $challenge_obj->creator_img;
					
	// user is the challenger
	} else {
		$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$user_arr['img'] = $challenge_obj->challenger_img;			
		
		// invited challenger if challenge status is 7
		if ($challenge_obj->status_id == "7")
			$query = 'SELECT `fb_id`, `username` FROM `tblInvitedUsers` WHERE `id` = '. $user_id .';';
	}
	
	// user object
	$user_obj = mysql_fetch_object(mysql_query($query));			
	if ($user_obj) {
		$user_arr['fb_id'] = $user_obj->fb_id;
		$user_arr['username'] = $user_obj->username;
		
		// find the avatar image
		if ($user_obj->img_url == "") {
			if ($user_obj->fb_id == "")
				$user_arr['avatar'] = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
			
			else
				$user_arr['avatar'] = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
	
		} else
			$user_arr['avatar'] = $user_obj->img_url;		
	}
	
	// votes for challenger
	$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
   	$score_result = mysql_query($query);
	
	// increment score
	while ($score_row = mysql_fetch_array($score_result, MYSQL_BOTH)) {										
		if ($score_row['challenger_id'] == $user_id)
			$user_arr['score']++;
	}
	
	// return
	return ($user_arr);
}

/* //SEND PUSH
$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = 3;';			
$creator_obj = mysql_fetch_object(mysql_query($query));
$device_token = $creator_obj->device_token;
$isPush = ($creator_obj->notifications == "Y");

echo ("isPush[".$isPush."] (".$device_token.")\n");

//if ($isPush == true) { 			
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
	curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ");
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "DERP has accepted your #lame challenge!", "sound": "push_01.caf"}}');
 	$res = curl_exec($ch);
	$err_no = curl_errno($ch);
	$err_msg = curl_error($ch);
	$header = curl_getinfo($ch);
	curl_close($ch); 
//}



$d_id = $argv[1];
//'d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed';
$msg = 'TWO BUTTON TEST!';
			
$ch = curl_init();
    
curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ");
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $d_id .'"], "type":"2", "aps": {"alert": "'. $msg .'"}}');

$res = curl_exec($ch);
$err_no = curl_errno($ch);
$err_msg = curl_error($ch);
$header = curl_getinfo($ch);
curl_close($ch);
*/



/* //MOVE CHALLENGER IMAGES & PARTICIPANTS INTO CHALLENGES TABLE
$query = 'SELECT `id` FROM `tblChallenges`;';
$challenge_result = mysql_query($query);
while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
	$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
	$participant_result = mysql_query($query);
	
	$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
	$img_result = mysql_query($query);
	
	$participant_id = (mysql_num_rows($participant_result) > 0) ? mysql_fetch_object($participant_result)->user_id : 0;
	$img_url = (mysql_num_rows($img_result) > 0) ? mysql_fetch_object($img_result)->url : "";
	
	$query = 'UPDATE `tblChallenges` SET `challenger_id` = "'. $participant_id .'", `challenger_img` = "'. $img_url .'" WHERE `id` = '. $challenge_row['id'] .';';
	$result = mysql_query($query);
}
*/


/* //REMOVE DUPLICATE VOTES ON CHALLENGE FROM SAME USER
$prev_arr = array('challenge_id' => 0, 'user_id' => 0);
$curr_arr = array('challenge_id' => 0, 'user_id' => 0);


$cnt = 0;
$id_arr = array();
$query = 'SELECT * FROM `tblChallengeVotes` ORDER BY `challenge_id`, `user_id`;';
$vote_result = mysql_query($query);
while ($vote_row = mysql_fetch_array($vote_result, MYSQL_BOTH)) {
	$prev_arr = $curr_arr;
	$curr_arr = array('challenge_id' => $vote_row['challenge_id'], 'user_id' => $vote_row['user_id']);
	
	if ($prev_arr['challenge_id'] == $curr_arr['challenge_id'] && $prev_arr['user_id'] == $curr_arr['user_id'])
		array_push($id_arr, $vote_row['id']);
}

foreach ($id_arr as $key) {
	echo ("REMOVE[". $key ."]\n");
	
	$query = 'DELETE FROM `tblChallengeVotes` WHERE `id` = '. $key .';';
	$result = mysql_query($query);
}
*/

/* //PREPEND # TO SUBJECTS
$query = 'SELECT * FROM `tblChallengeSubjects`;';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {	
	$query = 'UPDATE `tblChallengeSubjects` SET `title` = "'. "#" . $row['title'] .'" WHERE `id` = '. $row['id'] .';';
	$res = mysql_query($query);
}
*/


/* //SEND EMAIL W/ HEADERS
$user_id = 2;
$msg = "Lorem ipsum sit dolar amet!";
$query = "SELECT `username` FROM `tblUsers` WHERE `id` = {$user_id};";
$username = "gullinbursti"; //mysql_fetch_object(mysql_query($query))->username;


$to = "Matt Holcombe <matt.holcombe@gmail.com>, {$username} <{$username}@facebook.com>";
$subject = "Welcome to PicChallengeMe!";
$from = "PicChallenge <picchallenge@builtinmenlo.com>";

$headers_arr = array();
$headers_arr[] = "MIME-Version: 1.0";
$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
$headers_arr[] = "Content-Transfer-Encoding: 8bit";
$headers_arr[] = "From: {$from}";
$headers_arr[] = "Reply-To: {$from}";
$headers_arr[] = "Subject: {$subject}";
$headers_arr[] = "X-Mailer: PHP/". phpversion();

echo (mail($to, $subject, $msg, implode("\r\n", $headers_arr)) ."\n");
*/

/* //SHOW FB USERS
echo ("<html><head><meta charset=\"utf-8\"></head><body><table>\n");

$fb_arr = array();
$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `fb_id` != "";';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {	
	array_push($fb_arr, $row['fb_id']);
	echo ("<tr><td><a href='https://www.facebook.com/profile.php?id={$row['fb_id']}' target='_blank'>{$row['username']}</a></td><td>{$row['fb_id']}</td></tr>\n");
	//echo ("{$row['username']}@facebook.com,");
}			
echo ("</table></body></html>");
*/

/* // TWILIO TEST
$post_arr = array(
	'From' => "+12394313268",
	'To' => "+12393709811",
	'Body' => "Testing Twilio API"
);

$ch = curl_init();    
curl_setopt($ch, CURLOPT_URL, "https://api.twilio.com/2010-04-01/Accounts/ACb76dc4d9482a77306bc7170a47f2ea47/SMS/Messages.json");
curl_setopt($ch, CURLOPT_USERPWD, "ACb76dc4d9482a77306bc7170a47f2ea47:00015969db460ffe0f0bd5b3df60972a");
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: multipart/form-data"));
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_arr);

$res = curl_exec($ch);
$err_no = curl_errno($ch);
$err_msg = curl_error($ch);
$header = curl_getinfo($ch);
curl_close($ch);

//curl -X POST https://api.twilio.com/2010-04-01/Accounts/ACb76dc4d9482a77306bc7170a47f2ea47/SMS/Messages.json \
//    -u ACb76dc4d9482a77306bc7170a47f2ea47:00015969db460ffe0f0bd5b3df60972a \
//    -d "From=+12394313268" \
//    -d "To=+17143309754" \
//    -d 'Body=Testing Twilio API'
*/



/*
// DEFAULT NAMES
$defaultName_arr = array(
	"snap4snap",
	"picchampX",
	"swagluver",
	"coolswagger",
	"yoloswag",
	"tumblrSwag",
	"instachallenger",
	"hotbitchswaglove",
	"lovepeaceswaghot",
	"hotswaglover",
	"snapforsnapper",
	"snaphard",
	"snaphardyo",
	"yosnaper",
	"yoosnapyoo"
);

$query = 'SELECT `id`, `username` FROM `tblUsers` WHERE `username` LIKE "PicChallenge%";';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$rnd_ind = mt_rand(0, count($defaultName_arr) - 1);
	$username = $defaultName_arr[$rnd_ind] . $row['id'];

	//echo ("[". $row['id'] ."] --> ". $username ."<br />\n");
	echo ($row['id'] .", ");
	
	$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);				
}
*/


/* // UPDATE STARTED DATES
$query = 'SELECT `id`, `added` FROM `tblChallenges` WHERE `started` = "0000-00-00 00:00:00" ORDER BY `id` ASC;';
$result = mysql_query($query);

while ($row = mysql_fetch_assoc($result)) {
	echo ("[". $row['id'] ."] --> ". $row['added'] ."<br />\n");
	
	$query = 'UPDATE `tblChallenges` SET `started` = "'. $row['added'] .'" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);				
}
*/


/* // UPDATE VOTE SCORE

$vote_arr = array();
$query = 'SELECT `challenge_id` FROM `tblChallengeVotes`;';
$result = mysql_query($query);

while ($row = mysql_fetch_assoc($result))
	$vote_arr[$row['challenge_id']] = 0;
	
	
$query = 'SELECT `challenge_id` FROM `tblChallengeVotes`;';
$result = mysql_query($query);	

while ($row = mysql_fetch_assoc($result))
	$vote_arr[$row['challenge_id']]++;


foreach ($vote_arr as $key => $val) {
	echo ("CHALLENGE:[$key] = ($val)<br />\n");
	
	$query = 'UPDATE `tblChallenges` SET `votes` = "'. $val .'" WHERE `id` = '. $key .';';
	$result = mysql_query($query);
}
*/




// INSERT STARTING CHALLENGES
/*
if (isset($_GET['userID'])) {
	$user_id = $_GET['userID'];

	// starting users & snaps
	$snap_arr = array(
		array(// @jason #bestFriend
			'user_id' => "2393", 
			'subject_id' => "9", 
			'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc_0000000000"),
		array(// @tyler #snapAtMe
			'user_id' => "2394", 
			'subject_id' => "753", 
			'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000002"), 
		array(// @psy #me
			'user_id' => "2392", 
			'subject_id' => "28", 
			'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_0000000001") 
	);

	// loop thru user/snap array
	foreach ($snap_arr as $key => $val) {
	
		// add initial challenges
		$query = 'INSERT INTO `tblChallenges` (';
		$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
		$query .= 'VALUES (NULL, "2", "'. $val['subject_id'] .'", "'. $val['user_id'] .'", "'. $val['img_prefix'] .'", "'. $user_id .'", "", "N", "0", NOW(), NOW());';
		$result = mysql_query($query);
		$challenge_id = mysql_insert_id();
	
		echo ($query ."<br /><br />");
	}

} else {
	echo ("NO ['userID']!");
}
*/


/*
// fix updated dates
$query = 'SELECT `id`, `started` FROM `tblChallenges`;';
$result = mysql_query($query);

while ($row = mysql_fetch_assoc($result)) {
	$query = 'UPDATE `tblChallenges` SET `updated` = "'. $row['started'] .'" WHERE `id` = '. $row['id'] .';';
	$upd_result = mysql_query($query);
}
*/


/*
// challenge totals between users

if (!isset($_GET['userID'])) {
	echo ("Requires userID!");
	exit;
}

$user_id = $_GET['userID'];


// get challenge param IDs for this user
$challengeStat_arr = array();
$query = 'SELECT `id`, `creator_id`, `challenger_id` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `updated` DESC;';
$result = mysql_query($query);

// loop thru the rows, populate array
while ($row = mysql_fetch_object($result)) {
	$k = $row->id;//creator_id ."_". $row->challenger_id;
	$challengeStat_arr[$k] = array(
		'id' => $row->id, 
		'creator_id' => $row->creator_id, 
		'challenger_id' => $row->challenger_id);
}

print_r($challengeStat_arr);
echo("<hr /><br />");


// prime challenge pairing keys
$pairing_arr = array();
foreach ($challengeStat_arr as $key => $val) {
	//echo ("PRIME –[$key]—\»<br />[". $challengeStat_arr[$key]['creator_id'] ."_". $challengeStat_arr[$key]['challenger_id'] ."][". $challengeStat_arr[$key]['challenger_id'] ."_". $challengeStat_arr[$key]['creator_id'] ."]<br /><br />");
	
	// creator vs challenger
	$k = $challengeStat_arr[$key]['creator_id'] ."_". $challengeStat_arr[$key]['challenger_id'];
	$pairing_arr[$k][] = $key;
	
	// challenger vs creator
	$k = $challengeStat_arr[$key]['challenger_id'] ."_". $challengeStat_arr[$key]['creator_id'];
	$pairing_arr[$k][] = $key;
}

print_r($pairing_arr);
echo("<hr /><br />");


// flush rows that're creator/challenger reversed
$cnt = 0;
$flushID_arr = array();
$conden_arr = array();
foreach ($pairing_arr as $key => $val) {
	$id_arr = explode('_', $key);
	$k = $id_arr[1] ."_".  $id_arr[0];
	
	if ($cnt % 2 == 0) {
		echo("STATS –[$key]—»<br />[". count($val) ."] --> (");
		print_r($val);
		echo(")<br />");
	
		$pairing_arr[$key ."-". $k] = $pairing_arr[$key] + $pairing_arr[$k];//$conden_arr[$key ."-". $k] = $pairing_arr[$key] + $pairing_arr[$k];
	}
	
	$cnt++;
	//$ind = array_search($k, $pairing_arr);
	//echo("DUPS –[$key][$k]—»<br />@[$ind]<br />");
	//array_push($flushID_arr, $ind);
	echo ("[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]<br /><br />");
}

echo ("<hr /><hr />pairing_arr<br />");
print_r($pairing_arr);
echo ("<hr /><hr />");

echo ("pairing_arr<br />");
foreach ($pairing_arr as $key => $val) {
	echo("STATS –[$key]—»<br />[". count($val) ."] --> (");
	print_r($val);
	echo(")<br />[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]<br /><br />");
}

// push most recent challenge from each pairing into ID array
$challengeID_arr = array();
foreach ($pairing_arr as $key => $val) {
	$id_arr = explode('-', $key);
	$k = (count($id_arr) == 2) ? $id_arr[0] ."-". $id_arr[1] : "";
	
	if ($key == $k) {
		echo("VAL –[". $val[0] ."]<br />[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]<br /><br />");
		array_push($challengeID_arr, $val[0]);
	}
}


echo ("<hr />");
print_r($challengeID_arr);
echo("<hr /><br /><br />");

//$ind = 0; $ind = ($ind % 2 == 1) ? $ind++ : $ind;
// challenge lookup
$challenge_arr = array();
foreach ($challengeID_arr as $key => $val) {
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $val .';';
	$row = mysql_fetch_assoc(mysql_query($query));
	
	// set challenge status to waiting if user is the challenger and it's been created
	if ($row['challenger_id'] == $user_id && $row['status_id'] == "2")
		$row['status_id'] = "0";
	
	// get the subject title
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
	$sub_obj = mysql_fetch_object(mysql_query($query));
	
	// get total number of comments
	$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $row['id'] .';';
	$comments = mysql_num_rows(mysql_query($query));
	
	// push challenge into list
	array_push($challenge_arr, array(
		'id' => $row['id'], 
		'status' => $row['status_id'], 					
		'subject' => $sub_obj->title, 
		'comments' => $comments, 
		'has_viewed' => $row['hasPreviewed'], 
		'started' => $row['started'], 
		'added' => $row['added'], 
		'updated' => $row['updated'], 
		'creator' => userForChallenge($row['creator_id'], $row['id']),
		'challenger' => userForChallenge($row['challenger_id'], $row['id']),
		'rechallenges' => array()
	));
}


foreach ($challenge_arr as $key => $val) {
	echo("challenge_arr[$key]—» (");
	print_r($val);
	echo(")<br />[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]<br /><br />");
}
*/

function challengeOpponents($user_id) {
	
	// get challeges where user is the creator or the challenger
	$query = 'SELECT `creator_id`, `challenger_id` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND ((`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .')) ORDER BY `updated` DESC;';
	$result = mysql_query($query);
	
	// push opponent id
	$id_arr = array();
	while ($row = mysql_fetch_assoc($result))
		array_push($id_arr, ($user_id == $row['creator_id']) ? $row['challenger_id'] : $row['creator_id']);
		
	
	// return
	return (array_unique($id_arr));
}

function challengesWithOpponent($user_id, $opponent_id, $last_date="9999-99-99 99:99:99") {
	
	// get challenges where both users are included
	$query = 'SELECT `id`, `creator_id`, `challenger_id`, `updated` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND ((`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') AND (`creator_id` = '. $opponent_id .' OR `challenger_id` = '. $opponent_id .')) AND `updated` < "'. $last_date .'" ORDER BY `updated` DESC;';
	$result = mysql_query($query);
	
	// push challenge id as key & updated time as val
	while ($row = mysql_fetch_assoc($result))
		$challenge_arr[$row['id']] = $row['updated'];
		
	// return
	return ($challenge_arr);
}



// Load more
/*
if (!isset($_GET['userID'])) {
	echo ("Requires userID!");
	exit;
}

$user_id = $_GET['userID'];

//$user_id = 1;//2383;
$prevIDs = "2391|2|2383|1552|903|1064|1083|2169|2178|2365";
$date = "2013-04-26 11:29:31";
$prevID_arr = explode('|', $prevIDs);


// get list of past opponents & loop thru
$opponentID_arr = challengeOpponents($user_id);
echo ("opponentID_arr<br />");
print_r($opponentID_arr);
echo ("<hr />");
foreach($prevID_arr as $key => $val) {
	$ind = array_search($val, $opponentID_arr);
	
	// check against previous opponents
	if (is_numeric($ind))
		array_splice($opponentID_arr, $ind, 1);
}

echo ("opponentID_arr<br />");
print_r($opponentID_arr);
echo ("<hr />");
foreach($opponentID_arr as $key => $val) {
	
	// make sure it's not empty
	if (count(challengesWithOpponent($user_id, $val, $date)) > 0)
		$opponentChallenges_arr[$user_id .'_'. $val][] = challengesWithOpponent($user_id, $val, $date);
}

echo ("opponentChallenges_arr<br />");
print_r($opponentChallenges_arr);
echo ("<hr />");

// loop thru each paired match & pull off most recent
$challengeID_arr = array();
foreach($opponentChallenges_arr as $key => $val)
	array_push($challengeID_arr, key($val[0]));
	

// sort by date asc, then reverse to go desc
sort($challengeID_arr);
$challengeID_arr = array_reverse($challengeID_arr, true);

echo ("challengeID_arr<br />");
print_r($challengeID_arr);
echo ("<hr />");

// loop thru the most resent challenge ID per creator/challenger match
$cnt = 0;
$challenge_arr = array();
foreach ($challengeID_arr as $key => $val) {
	array_push($challenge_arr, $this->getChallengeObj($val));
	
	// stop at 10
	if (++$cnt == 10)
		break;
}
*/


if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>


</body></html>