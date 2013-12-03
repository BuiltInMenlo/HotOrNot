<?php

class Votes {
	//private $db_conn;

  	function __construct() {
		include_once './_inc/ApiProletariat.inc.php';
		include_once './_inc/ChallengePleb.inc.php';
		include_once './_inc/ResponsePleb.inc.php';
	
		//$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		//mysql_select_db('hotornot-dev') or die("Could not select database.");
	}

	function __destruct() {	
		/*if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}*/
	}
	
	
	/** 
	 * Gets the list of challenges sorted by total votes
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	function getChallengesByActivity() {
		
		// get waiting or started challenges
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 1 OR `status_id` = 4;';
		$result = mysql_query($query);
		
		// loop thru challenges, priming array
		$id_arr = array();
		while ($row = mysql_fetch_assoc($result))
			$id_arr[$row['id']] = 0;
		
		// get vote rows for challenges
		$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id` WHERE `tblChallenges`.`status_id` = 1 OR `tblChallenges`.`status_id` = 4;';
		$result = mysql_query($query);
		
		// loop thru votes, incrementing vote total array
		while ($row = mysql_fetch_assoc($result))
			$id_arr[$row['id']]++;
           
		// limit to 100, and sort
		$cnt = 0;
		arsort($id_arr);
		
		// loop thru each challenge id
		$challenge_arr = array();			
		foreach ($id_arr as $key => $val) {
			if ($cnt == 100)
				break;
			
			// push challenge into array
			array_push($challenge_arr, ChallengePleb::getChallengeObj($key));
			$cnt++;
		}
		
		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);			
	}
	
	/** 
	 * Gets the list of challenges sorted by date
	 * @return The list of challenges (array)
	**/
	function getChallengesByDate() {
		
		// get available challenge rows
		$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 1 OR `status_id` = 4 ORDER BY `updated` DESC LIMIT 250;';
		$result = mysql_query($query);
		
		// loop thru rows
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result)) {
			
			// push challenge into array
			array_push($challenge_arr, ChallengePleb::getChallengeObj($row['id']));
		}
			
		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/** 
	 * Gets the list of challenges for a subject
	 * @param $subject_id The ID of the subject (integer)
	 * @return The list of challenges (array)
	**/
	function getChallengesForSubjectID($subject_id) {
		
		// get challenges based on subject
		$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` = 1 OR `status_id` = 4) AND `subject_id` = '. $subject_id .' ORDER BY `updated` DESC;';
		$result = mysql_query($query);
		
		// loop thru challenges
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, ChallengePleb::getChallengeObj($row['id']));				

		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/** 
	 * Gets the list of challenges for a subject
	 * @param $subject_name The name of the subject (string)
	 * @return The list of challenges (array)
	**/
	function getChallengesForSubjectName($subject_name) {
		
		// get the subject id
		$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject_name .'";';
		$subject_id = mysql_fetch_object(mysql_query($query))->id;
		
		// get challenges based on subject
		$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` = 1 OR `status_id` = 4) AND `subject_id` = '. $subject_id .' ORDER BY `updated` DESC;';
		$result = mysql_query($query);
				
		// loop thru challenges
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, ChallengePleb::getChallengeObj($row['id']));				

		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	
	/** 
	 * Gets the latest list of 50 challenges for a user
	 * @param $username The username of the user (string)
	 * @return The list of challenges (array)
	**/
	function getChallengesForUsername($username) {
				
		// get the user's id
		$challenge_arr = array();
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
		$user_result = mysql_query($query);
		
		if (mysql_num_rows($user_result) == 0) {
			ApiProletariat::sendResponse(200, json_encode($challenge_arr));
			return (true);
		
		} else {
			$user_id = mysql_fetch_object($user_result)->id;
			
			// get latest 10 challenges for user
			$query = 'SELECT `id` FROM `tblChallenges` WHERE (`status_id` != 2 AND `status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `updated` DESC LIMIT 50;';
			$challenge_result = mysql_query($query);
		
			// loop thru the rows
			while ($challenge_row = mysql_fetch_assoc($challenge_result)) {
			
				// push challenge into list
				array_push($challenge_arr, ChallengePleb::getChallengeObj($challenge_row['id']));
			}
		
			// return
			ApiProletariat::sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
	}
	
	/** 
	 * Gets a list of challenges between two users
	 * @param $user_id The ID of the first user (integer)
	 * @param $challenger_id The ID of the second user (integer)
	 * @return The list of challenges (array)
	**/
	function getChallengesWithChallenger($user_id, $challenger_id) {
		
		// get challenges with these two users
		$query = 'SELECT `id` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' AND `challenger_id` = '. $challenger_id .') OR (`creator_id` = '. $challenger_id .' AND `challenger_id` = '. $user_id .') ORDER BY `updated` DESC LIMIT 50';
		$result = mysql_query($query);
		
		// loop thru challenges
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, ChallengePleb::getChallengeObj($row['id']));	
			
		
		// return
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/** 
	 * Gets a challenge for an ID
	 * @param $subject_id The ID of the subject (integer)
	 * @return An associative object of a challenge (array)
	**/
	function getChallengeForChallengeID($challenge_id) {
		
		// get challenge & return
		$challenge_arr = array();
		array_push($challenge_arr, ChallengePleb::getChallengeObj($challenge_id));
		ApiProletariat::sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	
	/** 
	 * Gets the voters for a particular challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @return An associative object of the users (array)
	**/
	function getVotersForChallenge($challenge_id) {		
		
		// get user votes for the challenge
		$query = 'SELECT `user_id`, `challenger_id`, `added` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' LIMIT 100;';
		$challenge_result = mysql_query($query);
		
		// loop thru votes
		$user_arr = array();
		while ($challenge_row = mysql_fetch_assoc($challenge_result)) {								
			
			// get user info
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_row['user_id'] .';';
			$user_obj = mysql_fetch_assoc(mysql_query($query));
			
			// get total challenges this user is involved in
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $user_obj->id .' OR `challenger_id` = '. $user_obj->id .';';
			$challenge_tot = mysql_num_rows(mysql_query($query));
			
			// calculate total upvotes for this user
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_obj->id .';';
			$votes = mysql_num_rows(mysql_query($query));
			
			// calculate total pokes for this user
			$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_obj->id .';';
			$pokes = mysql_num_rows(mysql_query($query));
			
			// get the person voted for
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['challenger_id'] .';';
			$challenger_name = mysql_fetch_object(mysql_query($query))->username;
			
			// push user into array
			array_push($user_arr, array(
				'id' => $user_obj['id'], 
				'fb_id' => $user_obj['fb_id'], 
				'username' => $user_obj['username'], 					
				'img_url' => UserPleb::avatarURLForUser($user_obj),   
				'points' => $user_obj['points'],
				'votes' => $votes,
				'pokes' => $pokes, 
				'challenges' => $challenge_tot, 
				'challenger_name' => $challenger_name,
				'added' => $challenge_row['added']
			));	
		}
		
		// return
		ApiProletariat::sendResponse(200, json_encode($user_arr));
		return (true);
	}
	
	/** 
	 * Upvotes a challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @param $user_id The ID of the user performing the upvote
	 * @param $isCreator Y/N whether or not the vote is for the challenge creator
	 * @return An associative object of the challenge (array)
	**/
	function upvoteChallenge($challenge_id, $user_id, $isCreator) {
		$apiProletariat = new ApiProletariat();
		
		// get challenge info
	    $query = 'SELECT `creator_id`, `subject_id`, `challenger_id`, `votes` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		$creator_id = $challenge_obj->creator_id;
		$challenger_id = $challenge_obj->challenger_id;
		$vote_tot = $challenge_obj->votes;
			
		// get any votes for this challenge by this user
		$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `user_id` = '. $user_id .';';
		$vote_result = mysql_query($query);
		
		// hasn't voted on this challenge
		if (mysql_num_rows($vote_result) == 0) {
			
			// assign vote
			$winningUser_id = ($isCreator == "Y") ? $creator_id : $challenger_id;
		
			// add vote record
			$query = 'INSERT INTO `tblChallengeVotes` (';
			$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';				
			$result = mysql_query($query);
			$vote_id = mysql_insert_id();
			
			// increment vote total & update time
			$query = 'UPDATE `tblChallenges` SET `votes` = "'. ++$vote_tot .'", `updated` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);
		
		// existing vote	
		} else
			$vote_id = mysql_fetch_object($vote_result)->id;
		
		// get all votes for this challenge
		$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
		$result = mysql_query($query);
		
		// calculate the scores
		$score_arr = array('creator' => 0, 'challenger' => 0);			
		while ($row = mysql_fetch_assoc($result)) {
			if ($row['challenger_id'] == $creator_id)
				$score_arr['creator']++;
				
			else
				$score_arr['challenger']++;
		}
		
		// get subject name
		$sub_name = ChallengePleb::subjectNameForChallenge($challenge_obj->subject_id);
		
		// send push to creator if votes equal a certain amount
		if ($winningUser_id == $creator_id && $score_arr['creator'] % 5 == 0) {
			$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
			$device_token = mysql_fetch_object(mysql_query($query))->device_token;
			
			$apiProletariat->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' snap has received '. $score_arr['creator'] .' upvotes!", "sound": "push_01.caf"}}');
		}
		
		// send push to challenger if votes equal a certain amount
		if ($winningUser_id == $challenger_id && $score_arr['challenger'] % 5 == 0) {
			$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
			$device_token = mysql_fetch_object(mysql_query($query))->device_token;
			
			$apiProletariat->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' snap has received '. $score_arr['challenger'] .' upvotes!", "sound": "push_01.caf"}}');
		}
		
		// return
		ApiProletariat::sendResponse(200, json_encode(ChallengePleb::getChallengeObj($challenge_id)));
		return (true);
	}
	
	
	/**
	 * Debugging function
	**/
	function test() {
		ApiProletariat::sendResponse(200, json_encode(array(
			'result' => true
		)));
		return (true);	
	}
}

$votes = new Votes;
////$votes->test();

// action was specified
if (isset($_POST['action'])) {
	switch ($_POST['action']) {
		case "0":
			$votes->test();
			break;
		
		// get list of challenges by votes
		case "1":				
			$votes->getChallengesByActivity();
			break;
		
		// get challenges for a subject
		case "2":
			if (isset($_POST['subjectID']))
				$votes->getChallengesForSubjectID($_POST['subjectID']);
			break;
			
		// get specific challenge				
		case "3":
			if (isset($_POST['challengeID']))
				$votes->getChallengeForChallengeID($_POST['challengeID']);
			break;
			
		// get a list of challenges by date
		case "4":
			$votes->getChallengesByDate();
			break;
			
		// get the voters for a challenge
		case "5":
			if (isset($_POST['challengeID']))
				$votes->getVotersForChallenge($_POST['challengeID']);
			break;
			
		// upvote a challenge	
		case "6":
			if (isset($_POST['challengeID']) && isset($_POST['userID']) && isset($_POST['creator']))
				$votes->upvoteChallenge($_POST['challengeID'], $_POST['userID'], $_POST['creator']);
			break;
		
		// get a list of challenges between two users
		case "7":
			if (isset($_POST['userID']) && isset($_POST['challengerID']))
				$votes->getChallengesWithChallenger($_POST['userID'], $_POST['challengerID']);
			break;
			
		// challenges by a subject name
		case "8":
			if (isset($_POST['subjectName']))
				$votes->getChallengesForSubjectName($_POST['subjectName']);
			break;
		
		case "9":
			if (isset($_POST['username']))
				$votes->getChallengesForUsername($_POST['username']);
			break;
   	}
}
?>