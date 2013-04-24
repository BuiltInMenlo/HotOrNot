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
		 * @return An associative object for a challenge (array)
		**/
		function getChallengeObj ($challenge_id) {
			$challenge_arr = array();
			
			// get challenge row
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			
			// get subject title for this challenge
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject_obj = mysql_fetch_object(mysql_query($query));
			
			// get total number of comments
			$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .';';
			$comments = mysql_num_rows(mysql_query($query));
			
			// get rechallenges
			$rechallenge_arr = array();
			$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj->subject_id .' AND `added` > "'. $challenge_obj->added .'" ORDER BY `added` ASC LIMIT 10;';
			$rechallenge_result = mysql_query($query);
			
			// loop thru the rows
			while ($rechallenge_row = mysql_fetch_assoc($rechallenge_result)) {
				$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $rechallenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				// find the avatar image
				if ($user_obj->img_url == "") {
					if ($user_obj->fb_id == "")
						$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
					
					else
						$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
			
				} else
					$avatar_url = $user_obj->img_url;
				
				array_push($rechallenge_arr, array(
					'id' => $rechallenge_row['id'],
					'user_id' => $rechallenge_row['creator_id'],
					'fb_id' => $user_obj->fb_id,
					'img_url' => $avatar_url,
					'username' => $user_obj->username,
					'added' => $rechallenge_row['added']
				));
			}
			
			// compose object
			$challenge_arr = array(
				'id' => $challenge_obj->id, 
				'status' => $challenge_obj->status_id, 
				'subject' => $subject_obj->title, 
				'comments' => $comments, 
				'has_viewed' => $challenge_obj->hasPreviewed, 
				'started' => $challenge_obj->started, 
				'added' => $challenge_obj->added, 
				'creator' => $this->userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
				'challenger' => $this->userForChallenge($challenge_obj->challenger_id, $challenge_obj->id),
				'rechallenges' => $rechallenge_arr
			); 
			
			// return
			return ($challenge_arr);
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
				$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_id` = '. $user_id .', `challenger_img` = "'. $img_url .'", `started` = NOW() WHERE `id` = '. $challenge_row['id'] .';';
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
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "1", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "0", "", "N", "0", NOW(), NOW());';
				$result = mysql_query($query);
				$challenge_id = mysql_insert_id();
				
				// get the newly created challenge info
				$challenge_arr = $this->getChallengeObj($challenge_id);				
			}
			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}
			*/
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
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "N", "0", NOW(), NOW());';
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
			
			/*
			example response:
			{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}
			*/
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
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `hasPreviewed`, `votes`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "N", "0", NOW(), NOW());';
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
			
			// couldn't find this user
			} else
				$challenge_arr = array("result" => "fail");					
			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}
			*/
		}
		
		/** 
		 * Gets the latest list of 10 challenges for a user
		 * @param $user_id The ID of the user (integer)
		 * @return The list of challenges (array)
		**/
		function getChallengesForUser($user_id) {
			$challenge_arr = array();			
			
			// get latest 10 challenges for user
			$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			// loop thru the rows
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				
				// set challenge status to waiting if user is the challenger and it's been created
				if ($challenge_row['challenger_id'] == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "0";
				
				// get the subject title
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				// push challenge into list
				array_push($challenge_arr, array(
					'id' => $challenge_row['id'], 
					'status' => $challenge_row['status_id'], 					
					'subject' => $sub_obj->title, 
					'has_viewed' => $challenge_row['hasPreviewed'], 
					'started' => $challenge_row['started'], 
					'added' => $challenge_row['added'],
					'creator' => $this->userForChallenge($challenge_row['creator_id'], $challenge_row['id']),
					'challenger' => $this->userForChallenge($challenge_row['challenger_id'], $challenge_row['id'])
				));
			}
			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			[{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}},{"id":"1206","status":"4","subject":"#LockedOutHeaven","has_viewed":"N","started":"2013-01-11 03:10:53","added":"2013-01-11 03:05:05","creator":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873486","score":0},"challenger":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873838","score":1}}]
			*/
		}
		
		
		/** 
		 * Gets the latest list of 10 challenges for a user
		 * @param $user_id The ID of the user (integer)
		 * @return The list of challenges (array)
		**/
		function getAllChallengesForUser($user_id) {
			$challenge_arr = array();			
			
			// get latest 10 challenges for user
			$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `added` DESC;';
			$challenge_result = mysql_query($query);
			
			// loop thru the rows
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				
				// set challenge status to waiting if user is the challenger and it's been created
				if ($challenge_row['challenger_id'] == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "0";
				
				// get the subject title
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				// get total number of comments
				$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$comments = mysql_num_rows(mysql_query($query));
			
				// get rechallenges
				$rechallenge_arr = array();
				$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_row['subject_id'] .' AND `added` > "'. $challenge_row['added'] .'" ORDER BY `added` ASC LIMIT 10;';
				$rechallenge_result = mysql_query($query);
			
				// loop thru the rows
				while ($rechallenge_row = mysql_fetch_assoc($rechallenge_result)) {
					$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $rechallenge_row['creator_id'] .';';
					$user_obj = mysql_fetch_object(mysql_query($query));
					
					// find the avatar image
					if ($user_obj->img_url == "") {
						if ($user_obj->fb_id == "")
							$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
					
						else
							$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
			
					} else
						$avatar_url = $user_obj->img_url;
				
				
					array_push($rechallenge_arr, array(
						'id' => $rechallenge_row['id'],
						'user_id' => $rechallenge_row['creator_id'],
						'fb_id' => $user_obj->fb_id,
						'img_url' => $avatar_url,
						'username' => $user_obj->username,
						'added' => $rechallenge_row['added']
					));
				}
				
				// push challenge into list
				array_push($challenge_arr, array(
					'id' => $challenge_row['id'], 
					'status' => $challenge_row['status_id'], 					
					'subject' => $sub_obj->title, 
					'comments' => $comments, 
					'has_viewed' => $challenge_row['hasPreviewed'], 
					'started' => $challenge_row['started'], 
					'added' => $challenge_row['added'],
					'creator' => $this->userForChallenge($challenge_row['creator_id'], $challenge_row['id']),
					'challenger' => $this->userForChallenge($challenge_row['challenger_id'], $challenge_row['id']),
					'rechallenges' => $rechallenge_arr
				));
			}
			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			[{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}},{"id":"1206","status":"4","subject":"#LockedOutHeaven","has_viewed":"N","started":"2013-01-11 03:10:53","added":"2013-01-11 03:05:05","creator":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873486","score":0},"challenger":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873838","score":1}}]
			*/
		}
		
		
		/** 
		 * Gets the next 10 challenges for a user prior to a date
		 * @param $user_id The user's ID to get challenges for (integer)
		 * @param $date the date/time to get challenges before (string)
		 * @return The list of challenges (array)
		**/
		function getChallengesForUserBeforeDate($user_id, $date) {
			$challenge_arr = array();			
			
			// get challenges
			$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` != 3 AND `status_id` != 6 AND `status_id` != 8) AND `added` < "'. $date .'" AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			// loop thru challenge rows
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				
				// set challenge status to waiting if user is the challenger and it's been created
				if ($challenge_row['challenger_id'] == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "0";
				
				// get the subject title
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				// push challenge into array
				array_push($challenge_arr, array(
					'id' => $challenge_row['id'], 
					'status' => $challenge_row['status_id'], 					
					'subject' => $sub_obj->title, 
					'has_viewed' => $challenge_row['hasPreviewed'], 
					'started' => $challenge_row['started'], 
					'added' => $challenge_row['added'],
					'creator' => $this->userForChallenge($challenge_row['creator_id'], $challenge_row['id']),
					'challenger' => $this->userForChallenge($challenge_row['challenger_id'], $challenge_row['id'])
				));
			}
			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			[{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}},{"id":"1206","status":"4","subject":"#LockedOutHeaven","has_viewed":"N","started":"2013-01-11 03:10:53","added":"2013-01-11 03:05:05","creator":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873486","score":0},"challenger":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873838","score":1}}]
			*/
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
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_id` = "'. $user_id .'", `challenger_img` = "'. $img_url .'", `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);			
			
			// return
			$this->sendResponse(200, json_encode(array(
				'id' => $challenge_id
			)));
			return (true);
			
			/*
			example response:
			{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}
			*/
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
			
			case "5":
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
				if (isset($_POST['userID']) && isset($_POST['datetime']))
					$challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['datetime']);
				break;
    	}
	}
?>