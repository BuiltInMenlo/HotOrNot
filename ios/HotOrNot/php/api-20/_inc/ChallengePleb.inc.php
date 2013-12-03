<?php

class ChallengePleb {
	
	//private $db_conn;
	
	public function __construct() {	
		include_once './_inc/UserPleb.inc.php';
		
		//$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		//mysql_select_db('hotornot-dev') or die("Could not select database.");
	}
	
	public function __destruct() {	
		/*if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}*/
	}
	
	
	/**
	 * Helper function that returns a challenge based on ID
	 * @param $challenge_id The ID of the challenge to get (integer)
	 * @return An associative object for a challenge (array)
	**/
	public static function getChallengeObj ($challenge_id, $user_id=0) {
			
		// get challenge row
		$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	
		// compose object & return
		return (array(
			'id' => $challenge_obj->id, 
			'status' => ($user_id != 0 && $user_id == $challenge_obj->challenger_id && $challenge_obj->status_id == "2") ? "0" : $challenge_obj->status_id, 
			'subject' => ChallengePleb::subjectNameForChallenge($challenge_obj->subject_id), 
			'comments' => ChallengePleb::commentTotalForChallenge($challenge_obj->id), 
			'has_viewed' => $challenge_obj->hasPreviewed, 
			'started' => $challenge_obj->started, 
			'added' => $challenge_obj->added, 
			'updated' => $challenge_obj->updated, 
			'creator' => ChallengePleb::userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
			'challenger' => ChallengePleb::userForChallenge($challenge_obj->challenger_id, $challenge_obj->id),
			'rechallenges' => ChallengePleb::rechallengesForChallenge(array('subject_id' => $challenge_obj->subject_id, 'added' => $challenge_obj->added))
		));
		
		// return
		return ($challenge_arr);
	}
	
	
	/**
	 * Helper function to user info for a challenge
	 * @param $user_id The creator or challenger ID (integer)
	 * @param $challenge_id The challenge's ID to get the user for (integer)
	 * @return An associative object for a user (array)
	**/
	public static function userForChallenge($user_id, $challenge_id) {
		
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
			if ($challenge_obj->status_id == "7") {
				$query = 'SELECT `fb_id`, `username` FROM `tblInvitedUsers` WHERE `id` = '. $user_id .';';
			}
		}
		
		// user object
		$user_obj = mysql_fetch_object(mysql_query($query));			
		if ($user_obj) {
			$user_arr['fb_id'] = $user_obj->fb_id;
			$user_arr['username'] = $user_obj->username;
			$user_arr['avatar'] = UserPleb::avatarURLForUser(array(
				'fb_id' => $user_obj->fb_id, 
				'img_url' => $user_arr['img']
			));
		}
		
		// votes for challenger
		$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
	   	$score_result = mysql_query($query);
		
		// increment score
		while ($score_row = mysql_fetch_assoc($score_result)) {
			if ($score_row['challenger_id'] == $user_id)
				$user_arr['score']++;
		}
		
		// return
		return ($user_arr);
	}

	/**
	 * Helper function to get the subject for a challenge
	 * @param $subject_id The ID of the subject (integer)
	 * @return Name of the subject (string)
	**/
	public static function subjectNameForChallenge($subject_id) {
		$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $subject_id .';';
		return (mysql_fetch_object(mysql_query($query))->title);
	}
	
	/**
	 * Helper function to get the total # of comments for a challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @return Total # of comments (integer)
	**/
	public static function commentTotalForChallenge($challenge_id) {
		$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .';';
		return (mysql_num_rows(mysql_query($query)));
	}
	
	/**
	 * Helper function to get the rechallenges for a challenge
	 * @param $challenge_obj The origin challenge (array)
	 * @return An associative object for a user (array)
	**/
	public static function rechallengesForChallenge($challenge_obj) {
		
		$rechallenge_arr = array();
		//$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj->subject_id .' AND `added` > "'. $challenge_obj->added .'" ORDER BY `added` ASC LIMIT 10;';
		$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj['subject_id'] .' AND `added` > "'. $challenge_obj['added'] .'" ORDER BY `added` ASC LIMIT 10;';
		$result = mysql_query($query);
	
		// loop thru the rows
		while ($row = mysql_fetch_assoc($result)) {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
			$user_obj = mysql_fetch_assoc(mysql_query($query));
			
			// push rechallenge into list
			array_push($rechallenge_arr, array(
				'id' => $row['id'],
				'user_id' => $row['creator_id'],
				'fb_id' => $user_obj['fb_id'],
				'img_url' => UserPleb::avatarURLForUser($user_obj),
				'username' => $user_obj['username'],
				'added' => $row['added']
			));
		}
		
		return ($rechallenge_arr);
	}
	
	/** 
	 * Helper function to build a list of opponents a user has played with
	 * @param $user_id The ID of the user to get challenges (integer)
	 * @return An array of user IDs (array)
	**/
	public static function challengeOpponents($user_id) {
		
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
	
	/** 
	 * Helper function to build a list of challenges between two users
	 * @param $user_id The ID of the 1st user to get challenges (integer)
	 * @param $opponent_id The ID of 2nd the user to get challenges (integer)
	 * @param $last_date The timestamp to start at (integer)
	 * @return An associative obj of challenge IDs paired w/ timestamp (array)
	**/
	public static function challengesWithOpponent($user_id, $opponent_id, $last_date="9999-99-99 99:99:99") {
		
		// get challenges where both users are included
		$query = 'SELECT `id`, `creator_id`, `challenger_id`, `updated` FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND ((`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') AND (`creator_id` = '. $opponent_id .' OR `challenger_id` = '. $opponent_id .')) AND `updated` < "'. $last_date .'" ORDER BY `updated` DESC;';
		$result = mysql_query($query);
		
		// push challenge id as key & updated time as val
		$challenge_arr = array();
		while ($row = mysql_fetch_assoc($result))
			$challenge_arr[$row['id']] = $row['updated'];
			
		// return
		return ($challenge_arr);
	}
	
	/**
	 * Checks to see if a user ID is a default
	 * @param $challenge_id The ID of the challenge
	 * @return An associative object for a challenge (array)
	**/
	public static function acceptChallengeAsDefaultUser($challenge_id) {
		
		// list of default user IDs
		$defaultUserID_arr = array(
			2390,
			2391,
			2392,
			2393,
			2394
		);
		
		// get challenge data
		$query = 'SELECT `subject_id`, `creator_id`, `challenger_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		
		// check for ID
		$isFound = false;
		foreach ($defaultUserID_arr as $key => $val) {
			if ($challenge_obj->challenger_id == $val) {
				$isFound = true;
				break;
			}
		}
		
		// found a default user
		if ($isFound) {
			
			// get the subject name for this challenge
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject_name = mysql_fetch_object(mysql_query($query))->title;
			
			// get default user info
			$query = 'SELECT `device_token`, `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			
			// pick a random image
			$img_url = "https://hotornot-challenges.s3.amazonaws.com/". $challenger_obj->device_token ."_000000000". mt_rand(0, 2);
			
			// get the creator's device info
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';			
			$creator_obj = mysql_fetch_object(mysql_query($query));
		
			// send push if allowed
			if ($creator_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $creator_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $challenger_obj->username .' has accepted your '. $subject_name .' snap!", "sound": "push_01.caf"}}'); 			

			// update the challenge to started
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_img` = "'. $img_url .'", `updated` = NOW(), `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);
		}
	}
	
	/** 
	 * Helper function that adds a new subject or returns the ID of the subject if already created
	 * @param $user_id The user's id that is adding the new subject (integer)
	 * @param $subject_name The text for the new subject (string)
	 * @return The new subject ID or existing subject's ID (integer)
	**/ 
	public static function submitSubject($user_id, $subject_name) {
		
		// if empty, assign as 'N/A'
		if ($subject_name == "")
			$subject_name = "N/A";
		
		// check to see if subject already exists
		$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject_name .'";';
		$result = mysql_query($query);
		
		// already exists, set subject_id
		if (mysql_num_rows($result) > 0) {
			$row = mysql_fetch_row($result);
			$subject_id = $row[0];
		
		// doesn't exist yet, insert and set subject_id
		} else {
			$query = 'INSERT INTO `tblChallengeSubjects` (';
			$query .= '`id`, `title`, `creator_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $subject_name .'", "'. $user_id .'", NOW());';
			$subject_result = mysql_query($query);
			$subject_id = mysql_insert_id();
		}
		
		// return
		return ($subject_id);	
	}
}

?>