<?php

	class Votes {
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
			
			// compose object
			$challenge_arr = array(
				'id' => $challenge_obj->id, 
				'status' => $challenge_obj->status_id, 
				'subject' => $subject_obj->title, 
				'has_viewed' => $challenge_obj->hasPreviewed, 
				'started' => $challenge_obj->started, 
				'added' => $challenge_obj->added, 
				'creator' => $this->userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
				'challenger' => $this->userForChallenge($challenge_obj->challenger_id, $challenge_obj->id) 
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
				'img' => "",
				'score' => 0				
			);
			
			// challenge object
			$query = 'SELECT `status_id`, `creator_id`, `challenger_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			
			// user is the creator
			if ($user_id == $challenge_obj->creator_id) {
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
				$user_arr['img'] = $challenge_obj->creator_img;
							
			// user is the challenger
			} else {
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
				$user_arr['img'] = $challenge_obj->challenger_img;			
				
				// invited challenger
				if ($challenge_obj->status_id == "7")
					$query = 'SELECT `fb_id`, `username` FROM `tblInvitedUsers` WHERE `id` = '. $user_id .';';
			}
			
			// user object
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			// votes for challenger
			$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
		   	$score_result = mysql_query($query);
						
			while ($score_row = mysql_fetch_array($score_result, MYSQL_BOTH)) {										
				if ($score_row['challenger_id'] == $user_id)
					$user_arr['score']++;
			}
			
			// user info
			if ($user_obj != null) {
				$user_arr['fb_id'] = $user_obj->fb_id;
				$user_arr['username'] = $user_obj->username; 		   			
			}
			
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
		 * Gets the list of challenges sorted by total votes
		 * @param $user_id The ID of the user (integer)
		 * @return The list of challenges (array)
		**/
		function getChallengesByActivity() {
			$challenge_arr = array();			
			$id_arr = array();
			
			// get waiting or started challenges
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 2 OR `status_id` = 4;';
			$result = mysql_query($query);
			
			// loop thru challenges, priming array
			while ($row = mysql_fetch_array($result, MYSQL_BOTH))
				$id_arr[$row['id']] = 0;
			
			// get vote rows for challenges
			$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id` WHERE `tblChallenges`.`status_id` = 2 OR `tblChallenges`.`status_id` = 4;';
			$result = mysql_query($query);
			
			// loop thru votes, incrementing vote total array
			while ($row = mysql_fetch_array($result, MYSQL_BOTH))
				$id_arr[$row['id']]++;
            
			// limit to 100, and sort
			$cnt = 0;
			arsort($id_arr);
			
			// loop thru each challenge id
			foreach ($id_arr as $key => $val) {
				if ($cnt == 100)
					break;
				
				// push challenge into array
				array_push($challenge_arr, $this->getChallengeObj($key));
				$cnt++;
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
		 * Gets the list of challenges sorted by date
		 * @return The list of challenges (array)
		**/
		function getChallengesByDate() {
			$challenge_arr = array();
			
			// get available challenge rows
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 1 OR `status_id` = 2 OR `status_id` = 4 ORDER BY `added` DESC LIMIT 100;';
			$result = mysql_query($query);
			
			// loop thru rows
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				
				// bug fix, skip challenge if waiting and has no challenge
				if ($row['status_id'] == "2" && $row['challenger_id'] == "0")
					continue;
				
				// push challenge into array
				array_push($challenge_arr, $this->getChallengeObj($row['id']));
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
		 * Gets the list of challenges for a subject
		 * @param $subject_id The ID of the subject (integer)
		 * @return The list of challenges (array)
		**/
		function getChallengesForSubject($subject_id) {
			$challenge_arr = array();
			
			// get challenges based on subject
			$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` = 1 OR `status_id` = 2 OR `status_id` = 4) AND `subject_id` = '. $subject_id .' ORDER BY `started` DESC;';
			$result = mysql_query($query);
			
			// loop thru challenges
			while ($row = mysql_fetch_array($result, MYSQL_BOTH))
				array_push($challenge_arr, $this->getChallengeObj($row['id']));				

			
			// return
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			[{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}},{"id":"1206","status":"4","subject":"#LockedOutHeaven","has_viewed":"N","started":"2013-01-11 03:10:53","added":"2013-01-11 03:05:05","creator":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873486","score":0},"challenger":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873838","score":1}}]
			*/
		}
		
		/** 
		 * Gets a challenge for an ID
		 * @param $subject_id The ID of the subject (integer)
		 * @return An associative object of a challenge (array)
		**/
		function getChallengeForChallengeID($challenge_id) {
			$challenge_arr = array();
			
			// get challenge & return
			array_push($challenge_arr, $this->getChallengeObj($challenge_id));
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
			
			/*
			example response:
			[{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}]
			*/
		}
		
		/** 
		 * Gets the voters for a particular challenge
		 * @param $challenge_id The ID of the challenge (integer)
		 * @return An associative object of the users (array)
		**/
		function getVotersForChallenge($challenge_id) {
			$user_arr = array();
			
			// get user votes for the challenge
			$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' LIMIT 100;';
			$challenge_result = mysql_query($query);
			
			// loop thru votes
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {								
				
				// get user info
				$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_row['user_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				// get total challenges this user is involved in
				$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $user_obj->id .' OR `challenger_id` = '. $user_obj->id .';';
				$challenge_tot = mysql_num_rows(mysql_query($query));
				
				// calculate total upvotes for this user
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_obj->id .';';
				$votes = mysql_num_rows(mysql_query($query));
				
				// calculate total pokes for this user
				$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_obj->id .';';
				$pokes = mysql_num_rows(mysql_query($query));
				
				// push user into array
				array_push($user_arr, array(
					'id' => $user_obj->id, 
					'fb_id' => $user_obj->fb_id, 
					'username' => $user_obj->username, 					
					'img_url' => "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square",   
					'points' => $user_obj->points,
					'votes' => $votes,
					'pokes' => $pokes, 
					'challenges' => $challenge_tot
				));	
			}
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			[{"id":"3","fb_id":"1390251585","username":"typeoh","img_url":"https:\/\/graph.facebook.com\/1390251585\/picture?type=square","points":"178","votes":187,"pokes":30,"challenges":470},{"id":"2","fb_id":"1554917948","username":"toofus.magnus","img_url":"https:\/\/graph.facebook.com\/1554917948\/picture?type=square","points":"50","votes":14,"pokes":22,"challenges":83}]
			*/
		}
		
		/** 
		 * Upvotes a challenge
		 * @param $challenge_id The ID of the challenge (integer)
		 * @param $user_id The ID of the user performing the upvote
		 * @param $isCreator Y/N whether or not the vote is for the challenge creator
		 * @return An associative object of the challenge (array)
		**/
		function upvoteChallenge($challenge_id, $user_id, $isCreator) {
			
			// get challenge info
		    $query = 'SELECT `creator_id`, `subject_id`, `challenger_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			$creator_id = $challenge_obj->creator_id;
			$challenger_id = $challenge_obj->challenger_id;
			
			// get subject name
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$sub_name = mysql_fetch_object(mysql_query($query))->title;
		
			// assign vote
			if ($isCreator == "Y")
				$winningUser_id = $creator_id;
							
			else
				$winningUser_id = $challenger_id;
				
			// get any votes for this challenge by this user
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `user_id` = '. $user_id .';';
			$vote_result = mysql_query($query);
			
			// hasn't voted on this challenge
			if (mysql_num_rows($vote_result) == 0) {							    
			
				// add vote record
				$query = 'INSERT INTO `tblChallengeVotes` (';
				$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
				$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';				
				$result = mysql_query($query);
				$vote_id = mysql_insert_id();
			
			// existing vote	
			} else
				$vote_id = mysql_fetch_object($vote_result)->id;
			
			// get all votes for this challenge
			$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
			$result = mysql_query($query);
			
			// calculate the scores
			$score_arr = array('creator' => 0, 'challenger' => 0);			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				if ($row['challenger_id'] == $creator_id)
					$score_arr['creator']++;
					
				else
					$score_arr['challenger']++;
			}
			
			// send push to creator if votes equal a certain amount
			if ($winningUser_id == $creator_id) {// && $score_arr['creator'] % 5 == 0) {
				$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
				$device_token = mysql_fetch_object(mysql_query($query))->device_token;
				
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' challenge has received '. $score_arr[0] .' upvotes!", "sound": "push_01.caf"}}');
			}
			
			// send push to challenger if votes equal a certain amount
			if ($winningUser_id == $challenger_id) {// && $score_arr['challenger'] % 5 == 0) {
				$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
				$device_token = mysql_fetch_object(mysql_query($query))->device_token;
				
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"1", "aps": {"alert": "Your '. $sub_name .' challenge has received '. $score_arr[1] .' upvotes!", "sound": "push_01.caf"}}');
			}
			
			// return
			$this->sendResponse(200, json_encode($this->getChallengeObj($challenge_id)));
			return (true);
			
			/*
			example response:
			{"id":"1207","status":"4","subject":"#Scream&Shout","has_viewed":"N","started":"2013-01-11 03:06:16","added":"2013-01-11 03:05:51","creator":{"id":"3","fb_id":"1390251585","username":"typeoh","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/fb984c1100eb39b30090fb2dcabc1e8ec47f34ff9aab50ce710204977384e460_1357873534","score":0},"challenger":{"id":"876","fb_id":"","username":"PicChallenge876","img":"https:\/\/hotornot-challenges.s3.amazonaws.com\/15239dd5a62a822bcbf51b9f5071189d728b12adacf5092c4d9ff4533306a1f3_1357873561","score":1}}
			*/
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
	
	$votes = new Votes;
	//$votes->test();
	
	// action was specified
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			case "0":
				break;
			
			// get list of challenges by votes
			case "1":				
				$votes->getChallengesByActivity();
				break;
			
			// get challenges for a subject
			case "2":
				if (isset($_POST['subjectID']))
					$votes->getChallengesForSubject($_POST['subjectID']);
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
    	}
	}
?>