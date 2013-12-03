<?php

	class Challenges {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('hotornot-dev') or die("Could not select database.");
		}
	
		function __destruct() {	
			if ($this->db_conn) {
				mysql_close($this->db_conn);
				$this->db_conn = null;
			}
		}
		
		
		function getStatusCodeMessage($status) {			
			$codes = array(
				100 => 'Continue',
				101 => 'Switching Protocols',
				200 => 'OK',
				201 => 'Created',
				202 => 'Accepted',
				203 => 'Non-Authoritative Information',
				204 => 'No Content',
				205 => 'Reset Content',
				206 => 'Partial Content',
				300 => 'Multiple Choices',
				301 => 'Moved Permanently',
				302 => 'Found',
				303 => 'See Other',
				304 => 'Not Modified',
				305 => 'Use Proxy',
				306 => '(Unused)',
				307 => 'Temporary Redirect',
				400 => 'Bad Request',
				401 => 'Unauthorized',
				402 => 'Payment Required',
				403 => 'Forbidden',
				404 => 'Not Found',
				405 => 'Method Not Allowed',
				406 => 'Not Acceptable',
				407 => 'Proxy Authentication Required',
				408 => 'Request Timeout',
				409 => 'Conflict',
				410 => 'Gone',
				411 => 'Length Required',
				412 => 'Precondition Failed',
				413 => 'Request Entity Too Large',
				414 => 'Request-URI Too Long',
				415 => 'Unsupported Media Type',
				416 => 'Requested Range Not Satisfiable',
				417 => 'Expectation Failed',
				500 => 'Internal Server Error',
				501 => 'Not Implemented',
				502 => 'Bad Gateway',
				503 => 'Service Unavailable',
				504 => 'Gateway Timeout',
				505 => 'HTTP Version Not Supported');

			return ((isset($codes[$status])) ? $codes[$status] : '');
		}
				
		function sendResponse($status=200, $body='', $content_type='text/json') {			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			
			header($status_header);
			header("Content-type: ". $content_type);
			
			echo ($body);
		}
		
		/** 
		 * Helper function that adds a new subject or returns the ID of the subject if already created
		 * @param $user_id The user's id that is adding the new subject (integer)
		 * @param $subject_name The text for the new subject (string)
		 * @return The new subject ID or existing subject's ID (integer)
		**/ 
		function submitSubject($user_id, $subject_name) {
			
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
		
		/**
		 * Helper function that returns a challenge based on ID
		 * @param $challenge_id The ID of the challenge to get (integer)
		 * @param $user_id The ID of a user for this challenge (integer)
		 * @return An associative object for a challenge (array)
		**/
		function getChallengeObj ($challenge_id, $user_id=0) {
			
			// get challenge row
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			
			
			// compose object & return
			return (array(
				'id' => $challenge_obj->id, 
				'status' => ($user_id != 0 && $user_id == $challenge_obj->challenger_id && $challenge_obj->status_id == "2") ? "0" : $challenge_obj->status_id, 
				'subject' => $this->subjectNameForChallenge($challenge_obj->subject_id), 
				'comments' => $this->commentTotalForChallenge($challenge_obj->id), 
				'has_viewed' => $challenge_obj->hasPreviewed, 
				'started' => $challenge_obj->started, 
				'added' => $challenge_obj->added, 
				'updated' => $challenge_obj->updated, 
				'creator' => $this->userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
				'challenger' => $this->userForChallenge($challenge_obj->challenger_id, $challenge_obj->id),
				'rechallenges' => $this->rechallengesForChallenge(array('subject_id' => $challenge_obj->subject_id, 'added' => $challenge_obj->added))
			));
		}
		
		/**
		 * Helper function to get the subject for a challenge
		 * @param $subject_id The ID of the subject (integer)
		 * @return Name of the subject (string)
		**/
		function subjectNameForChallenge($subject_id) {
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $subject_id .';';
			return (mysql_fetch_object(mysql_query($query))->title);
		}
		
		/**
		 * Helper function to get the total # of comments for a challenge
		 * @param $challenge_id The ID of the challenge (integer)
		 * @return Total # of comments (integer)
		**/
		function commentTotalForChallenge($challenge_id) {
			$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .';';
			return (mysql_num_rows(mysql_query($query)));
		}
		
		/**
		 * Helper function to get the rechallenges for a challenge
		 * @param $challenge_obj The origin challenge (array)
		 * @return An associative object for a user (array)
		**/
		function rechallengesForChallenge($challenge_obj) {
			
			$rechallenge_arr = array();
			//$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj->subject_id .' AND `added` > "'. $challenge_obj->added .'" ORDER BY `added` ASC LIMIT 10;';
			$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj['subject_id'] .' AND `added` > "'. $challenge_obj['added'] .'" ORDER BY `added` ASC LIMIT 10;';
			$result = mysql_query($query);
		
			// loop thru the rows
			while ($row = mysql_fetch_assoc($result)) {
				$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				// find the avatar image
				$avatar_url = $this->avatarURLForUser($user_obj);
				
				// push rechallenge into list
				array_push($rechallenge_arr, array(
					'id' => $row['id'],
					'user_id' => $row['creator_id'],
					'fb_id' => $user_obj->fb_id,
					'img_url' => $avatar_url,
					'username' => $user_obj->username,
					'added' => $row['added']
				));
			}
			
			return ($rechallenge_arr);
		}
		
		/**
		 * Helper function to get the correct user avatar
		 * @param $user_obj A associative object of the user (array)
		 * @return A url to an image (string)
		**/
		function avatarURLForUser($user_obj) {
			
			// no custom url
			if ($user_obj->img_url == "") {
				
				// no fb either, use default
				if ($user_obj->fb_id == "")
					return ("https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png");
				
				// fb avatar
				else
					return ("https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square");
			}
			
			// use custom
			return ($user_obj->img_url);
		}
			
		/**
		 * Helper function to user info for a challenge
		 * @param $user_id The creator or challenger ID (integer)
		 * @param $challenge_id The challenge's ID to get the user for (integer)
		 * @return An associative object for a user (array)
		**/
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
				$user_arr['avatar'] = $this->avatarURLForUser($user_obj);
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
		 * Helper function to build a list of opponents a user has played with
		 * @param $user_id The ID of the user to get challenges (integer)
		 * @return An array of user IDs (array)
		**/
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
		
		/** 
		 * Helper function to build a list of challenges between two users
		 * @param $user_id The ID of the 1st user to get challenges (integer)
		 * @param $opponent_id The ID of 2nd the user to get challenges (integer)
		 * @param $last_date The timestamp to start at (integer)
		 * @return An associative obj of challenge IDs paired w/ timestamp (array)
		**/
		function challengesWithOpponent($user_id, $opponent_id, $last_date="9999-99-99 99:99:99") {
			
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
		 * Helper function to send an Urban Airship push
		 * @param $msg The message body of the push (string)
		 * @return null
		**/
		function sendPush($msg) {
			// curl urban airship's api
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
			//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
			curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_POST, 1);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
		 	$res = curl_exec($ch);
			$err_no = curl_errno($ch);
			$err_msg = curl_error($ch);
			$header = curl_getinfo($ch);
			curl_close($ch);
			
			// curl urban airship's api
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
			curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
			//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_POST, 1);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
		 	$res = curl_exec($ch);
			$err_no = curl_errno($ch);
			$err_msg = curl_error($ch);
			$header = curl_getinfo($ch);
			curl_close($ch);
		}
		
		/**
		 * Checks to see if a user ID is a default
		 * @param $challenge_id The ID of the challenge
		 * @return An associative object for a challenge (array)
		**/
		function acceptChallengeAsDefaultUser($challenge_id) {
			
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
			$to = "bim.picchallenge@gmail.com";
			$subject = "Flagged Challenge";
			$body = "Challenge ID: #". $challenge_id ."\nFlagged By User: #". $user_id;
			$from = "picchallenge@builtinmenlo.com";
			
			$headers_arr = array();
			$headers_arr[] = "MIME-Version: 1.0";
			$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
			$headers_arr[] = "Content-Transfer-Encoding: 8bit";
			$headers_arr[] = "From: {$from}";
			$headers_arr[] = "Reply-To: {$from}";
			$headers_arr[] = "Subject: {$subject}";
			$headers_arr[] = "X-Mailer: PHP/". phpversion();

			if (mail($to, $subject, $body, implode("\r\n", $headers_arr))) 
			   $mail_res = true;

			else
			   $mail_res = false;  
			
			// return
			$this->sendResponse(200, json_encode(array(
				'id' => $challenge_id,
				'mail' => $mail_res
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