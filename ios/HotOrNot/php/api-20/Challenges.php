<?php

class Challenges {
	private $db_conn;

  	function __construct() {
		include_once './_inc/ApiProletariat.inc.php';
		include_once './_inc/ChallengePleb.inc.php';
		include_once './_inc/ResponsePleb.inc.php';
		include_once './_inc/UserPleb.inc.php';
	
		$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		mysql_select_db('hotornot-dev') or die("Could not select database.");
	}

	function __destruct() {	
		if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}
	}
	
	
	/**
	 * Inserts a new challenge and attempts to match on a waiting challenge with the same subject
	 * @param $user_id The ID of the user submitting the challenge (integer)
	 * @param $subject The subject for the challenge
	 * @param $img_url The URL to the image for the challenge
	 * @return An associative object for a challenge (array)
	**/
	function submitMatchingChallenge($user_id, $subject, $img_url) {
		$challenge_arr = array();			
		
		// get the subject id for subject name
		$subject_id = $this->submitSubject($user_id, $subject);
		
		// prime the list of available challenges
		$rndChallenge_arr = array();
		
		// get any pending challenges for this subject that isn't created by this user
		$query = 'SELECT `id`, `creator_id` FROM `tblChallenges` WHERE `status_id` = 1 AND `subject_id` = '. $subject_id .' AND `creator_id` != '. $user_id .';';
		$challenge_result = mysql_query($query);
		
		// found some waiting challenges
		if (mysql_num_rows($challenge_result) > 0) {			
			
			// push into available challenge array
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH))
				array_push($rndChallenge_arr, $challenge_row);
			
			// pick a random challenge from list
			$rnd_ind = mt_rand(0, count($rndChallenge_arr) - 1);
			$challenge_row = $rndChallenge_arr[$rnd_ind];
			
			// get the challenge creator's info
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));							
			
			// get user's info as the challenger
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			
			// update the challenge to say it's nowe in session
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_id` = '. $user_id .', `challenger_img` = "'. $img_url .'", `updated` = NOW(), `started` = NOW() WHERE `id` = '. $challenge_row['id'] .';';
			$update_result = mysql_query($query);
			
			// send push if creator allows it
			if ($creator_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $creator_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $challenger_obj->username .' has accepted your '. $subject .' snap!", "sound": "push_01.caf"}}');
			
		    
			// get the updated challenge info 
			$challenge_arr = $this->getChallengeObj($challenge_row['id']);
		
		// no available challenges found with this subject
		} else {
			
			// get the user's info as creator
			$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));				
			$points = $creator_obj->points;			
			
			// increment the user's points
			$query = 'UPDATE `tblUsers` SET `points` = "'. ($points + 1) .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			// add challenge as waiting for someone
			$query = 'INSERT INTO `tblChallenges` (';
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `updated`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "1", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "0", "", "N", "0", NOW(), NOW(), NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			// get the newly created challenge info
			$challenge_arr = $this->getChallengeObj($challenge_id);				
		}
		
		// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/**
	 * Submits a new challenge to a specific user
	 * @param $user_id The user submitting the challenge (integer)
	 * @param $subject The challenge's subject (string)
	 * @param $img_url The URL to the challenge's image (string)
	 * @param $challenger_id The ID of the user to target (integer)
	 * @return An associative object for a challenge (array)
	**/
	function submitChallengeWithChallenger($user_id, $subject, $img_url, $challenger_id) {
		$challenge_arr = array();
		
		// get the subject id for the subject name
		$subject_id = $this->submitSubject($user_id, $subject);
		
		// get the user's info as the creator
		$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$creator_obj = mysql_fetch_object(mysql_query($query));
		$points = $creator_obj->points;
		
		// increment the user's points
		$query = 'UPDATE `tblUsers` SET `points` = "'. ($points + 1) .'" WHERE `id` ='. $user_id .';';
		$result = mysql_query($query);
		
		// add the challenge
		$query = 'INSERT INTO `tblChallenges` (';
		$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `updated`, `started`, `added`) ';
		$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "N", "0", NOW(), NOW(), NOW());';
		$result = mysql_query($query);
		$challenge_id = mysql_insert_id();
		
		// get the targeted user's info
		$query = 'SELECT `device_token`, `username`, `fb_id`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
		$challenger_obj = mysql_fetch_object(mysql_query($query));
		
		// send push to targeted user if allowed
		if ($challenger_obj->notifications == "Y")
			$this->sendPush('{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $creator_obj->username .' has sent you a '. $subject .' snap!", "sound": "push_01.caf"}}');
		
		// get the newly created challenge
		$challenge_arr = $this->getChallengeObj($challenge_id);
		
		/// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/**
	 * Submits a new challenge to a specific user
	 * @param $user_id The user submitting the challenge (integer)
	 * @param $subject The challenge's subject (string)
	 * @param $img_url The URL to the challenge's image (string)
	 * @param $username The username of the user to target (string)
	 * @return An associative object for a challenge (array)
	**/
	function submitChallengeWithUsername($user_id, $subject, $img_url, $username) {
		$challenge_arr = array();
		
		// get the targeted user's info
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
		$challenger_result = mysql_query($query);
		
		// user was found based on username
		if (mysql_num_rows($challenger_result) > 0) {			
			$challenger_id = mysql_fetch_object($challenger_result)->id;
			
			// look for default users
			
			// get the subject id for the subject name
			$subject_id = $this->submitSubject($user_id, $subject);
			
			// get the user's info as the creator
			$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));				
			$points = $creator_obj->points;
			
			// increment the points
			$query = 'UPDATE `tblUsers` SET `points` = "'. ($points + 1) .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			// add the new challenge
			$query = 'INSERT INTO `tblChallenges` (';
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `updated`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "N", "0", NOW(), NOW(), NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			// get targeted user's info for push
			$query = 'SELECT `device_token`, `username`, `fb_id`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			
			// send push if allowed
			if ($challenger_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $creator_obj->username .' has sent you a '. $subject .' snap!", "sound": "push_01.caf"}}');
		    
			// get the newly created challenge
			$challenge_arr = $this->getChallengeObj($challenge_id);
			
			
			// auto-accept if sent to default user
			$this->acceptChallengeAsDefaultUser($challenge_id);
			
		
		// couldn't find this user
		} else
			$challenge_arr = array("result" => "fail");					
		
		// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	
	/** 
	 * Gets all the challenges for a user
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	function getAllChallengesForUser($user_id) {
		
		// get challenges for user
		$query = 'SELECT `id` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `updated` DESC;';
		$result = mysql_query($query);
		
		// loop thru the rows
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result))
			array_push($challenge_arr, $this->getChallengeObj($row['id']));
		
		// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/** 
	 * Gets the latest list of challenges for a user and the challengers
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	function getChallengesForUser($user_id) {
		
		// get list of past opponents & loop thru
		$opponentID_arr = $this->challengeOpponents($user_id);
		foreach($opponentID_arr as $key => $val)
			$opponentChallenges_arr[$user_id .'_'. $val][] = $this->challengesWithOpponent($user_id, $val);
		
		// loop thru each paired match & pull off most recent
		$challengeID_arr = array();
		foreach($opponentChallenges_arr as $key => $val)
			array_push($challengeID_arr, key($val[0]));
			
		
		// sort by date asc, then reverse to go desc
		asort($challengeID_arr);
		$challengeID_arr = array_reverse($challengeID_arr, true);
		
		
		// loop thru the most resent challenge ID per creator/challenger match
		$cnt = 0;
		$challenge_arr = array();
		foreach ($challengeID_arr as $key => $val) {
			array_push($challenge_arr, $this->getChallengeObj($val));
			
			// stop at 10
			if (++$cnt == 10)
				break;
		}
			
		
		// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	
	/** 
	 * Gets the next 10 challenges for a user prior to a date
	 * @param $user_id The user's ID to get challenges for (integer)
	 * @param $date the date/time to get challenges before (string)
	 * @return The list of challenges (array)
	**/
	function getChallengesForUserBeforeDate($user_id, $prevIDs, $date) {
		$prevID_arr = explode('|', $prevIDs);
		
		
		// get list of past opponents & loop thru
		$opponentID_arr = $this->challengeOpponents($user_id);
		
		// loop thru prev id & remove from opponent array
		foreach($prevID_arr as $key => $val) {
			$ind = array_search($val, $opponentID_arr);
			
			// check against previous opponents
			if (is_numeric($ind))
				array_splice($opponentID_arr, $ind, 1);
		}

		// loop thru opponents & build paired array
		foreach($opponentID_arr as $key => $val) {
			
			// check against previous opponents
			if (count($this->challengesWithOpponent($user_id, $val, $date)) > 0)
				$opponentChallenges_arr[$user_id .'_'. $val][] = $this->challengesWithOpponent($user_id, $val, $date);
		}
		
		
		// loop thru each paired match & pull off most recent
		$challengeID_arr = array();
		foreach($opponentChallenges_arr as $key => $val) 
			array_push($challengeID_arr, key($val[0]));
			
		
		// sort by date asc, then reverse to go desc
		asort($challengeID_arr);
		$challengeID_arr = array_reverse($challengeID_arr, true);
		
		
		// loop thru the most resent challenge ID per creator/challenger match
		$cnt = 0;
		$challenge_arr = array();
		foreach ($challengeID_arr as $key => $val) {
			array_push($challenge_arr, $this->getChallengeObj($val));
			
			// stop at 10
			if (++$cnt == 10)
				break;
		}
		
		// return
		$this->sendResponse(200, json_encode($challenge_arr));
		return (true);
	}
	
	/**
	 * Updates a challenge with a challenger
	 * @param $user_id The user's ID who is accepting the challenge (integer)
	 * @param $challenge_id the ID of the challenge being accepted (integer)
	 * @param $img_url The URL to the challenger's image (string)
	 * @return The ID of the challenge (integer)
	**/
	function acceptChallenge($user_id, $challenge_id, $img_url) {
		$challenge_arr = array();
		
		// get the user's name
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
		$challenger_name = mysql_fetch_object(mysql_query($query))->username; 
		
		// get the subject & the id of the user that created the challenge
		$query = 'SELECT `subject_id`, `creator_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		
		// get the subject name for this challenge
		$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
		$subject_name = mysql_fetch_object(mysql_query($query))->title;
		
		// get the creator's device info
		$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';			
		$creator_obj = mysql_fetch_object(mysql_query($query));
		$isPush = ($creator_obj->notifications == "Y");
		
		// send push if allowed
		if ($isPush)
			$this->sendPush('{"device_tokens": ["'. $creator_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $challenger_name .' has accepted your '. $subject_name .' snap!", "sound": "push_01.caf"}}'); 			

		// update the challenge to started
		$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_id` = "'. $user_id .'", `challenger_img` = "'. $img_url .'", `updated` = NOW(), `started` = NOW() WHERE `id` = '. $challenge_id .';';
		$result = mysql_query($query);			
		
		// return
		$this->sendResponse(200, json_encode(array(
			'id' => $challenge_id
		)));
		return (true);
	}
	
	/**
	 * Updates a challenge to being canceled
	 * @param $challenge_id The challenge to update (integer)
	 * @return The ID of the challenge (integer)
	**/
	function cancelChallenge ($challenge_id) {
		// update the challenge status
		$query = 'UPDATE `tblChallenges` SET `status_id` = 3 WHERE `id` = '. $challenge_id .';';
		$result = mysql_query($query);			
		
		// return
		$this->sendResponse(200, json_encode(array(
			'id' => $challenge_id
		)));
		return (true);
	}
	
	/** 
	 * Flags the challenge for abuse / inappropriate content
	 * @param $user_id The user's ID who is claiming abuse (integer)
	 * @param $challenge The ID of the challenge to flag (integer)
	 * @return An associative object (array)
	**/
	function flagChallenge ($user_id, $challenge_id) {
		// update the challenge status
		$query = 'UPDATE `tblChallenges` SET `status_id` = 6 WHERE `id` = '. $challenge_id .';';
		$result = mysql_query($query);
		
		// insert record to flagged challenges
		$query = 'INSERT INTO `tblFlaggedChallenges` (';
		$query .= '`challenge_id`, `user_id`, `added`) VALUES (';
		$query .= '"'. $challenge_id .'", "'. $user_id .'", NOW());';				
		$result = mysql_query($query);
		
		// send email
		$mail_res = ApiProletariat::sendEmail("bim.picchallenge@gmail.com", "Flagged Challenge", "Challenge ID: #$user_id\nFlagged By User: #$user_id");		
		
		// return
		$this->sendResponse(200, json_encode(array(
			'id' => $challenge_id,
			'result' => $mail_res['result']
		)));
		return (true);
	}
			
	/** 
	 * Updates a challenge that has been opened
	 * @param $challenge_id The ID of the challenge
	 * @return An associative array with the challenge's ID
	**/
	function updatePreviewed ($challenge_id) {
		
		// update the challenge status
		$query = 'UPDATE `tblChallenges` SET `hasPreviewed` = "Y" WHERE `id` = '. $challenge_id .';';
		$result = mysql_query($query);
		
		// return
		$this->sendResponse(200, json_encode(array(
			'id' => $challenge_id
		)));
		return (true);
	}
	
	
	/**
	 * Gets the iTunes info for a specific challenge subject
	 * @param $subject_name The subject to look up (string)
	 * @return An associative array
	**/
	function getPreviewForSubject ($subject_name) {

		// return
		$this->sendResponse(200, json_encode(array(
			'id' => 0, 
			'title' => $subject_name, 
			'preview_url' => "",
			'artist' => "",
			'song_name' => "",
			'img_url' => "",
			'itunes_url' => "",
			'linkshare_url' => ""
		)));
		
		return (true);
	}
	
	
	
	/** 
	 * Debugging function
	**/
	function test() {
		$this->sendResponse(200, json_encode(array(
			'result' => true
		)));
		return (true);	
	}
}

$challenges = new Challenges;
////$challenges->test();


// there's an action specified
if (isset($_POST['action'])) {
	
	// call function depending on action
	switch ($_POST['action']) {	
		case "0":
			$challenges->test();
			break;
		
		// submit an auto-matching challenge	
		case "1":
			if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']))
				$challenges->submitMatchingChallenge($_POST['userID'], $_POST['subject'], $_POST['imgURL']);
			break;
		
		// get challenges for a user
		case "2":
			if (isset($_POST['userID']))
				$challenges->getChallengesForUser($_POST['userID']);
			break;
			
		case "3":
			if (isset($_POST['userID']))
				$challenges->getAllChallengesForUser($_POST['userID']);
			break;
		
		// accept a challenge
		case "4":
			if (isset($_POST['userID']) && isset($_POST['challengeID']) && isset($_POST['imgURL']))
				$challenges->acceptChallenge($_POST['userID'], $_POST['challengeID'], $_POST['imgURL']);
			break;
		
		// legacy function for itunes subject lookup
		case "5":
			if (isset($_POST['subjectName']))
				$challenges->getPreviewForSubject($_POST['subjectName']);
			break;
		
		// update a challenge as being viewed
		case "6":
			if (isset($_POST['challengeID']))
				$challenges->updatePreviewed($_POST['challengeID']);
			break;
		
		// submit a new challenge to a user
		case "7":
			if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['username']))
				$challenges->submitChallengeWithUsername($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['username']);
			break;
		
		case "8":
			break;
		
		// submit a challenge to a user
		case "9":
			if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['challengerID']))
				$challenges->submitChallengeWithChallenger($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['challengerID']);
			break;
		
		// update a challenge as being canceled
		case "10":
			if (isset($_POST['challengeID']))
				$challenges->cancelChallenge($_POST['challengeID']);
			break;
		
		// update a challenge as being inappropriate / abuse 
		case "11":
			if (isset($_POST['userID']) && isset($_POST['challengeID']))
				$challenges->flagChallenge($_POST['userID'], $_POST['challengeID']);
			break;
		
		// get challenges for a user prior to a date
		case "12":
			if (isset($_POST['userID']) && isset($_POST['prevIDs']) && isset($_POST['datetime']))
				$challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['prevIDs'], $_POST['datetime']);
			break;
   	}
}
?>