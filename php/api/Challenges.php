<?php

	class Challenges {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('hotornot') or die("Could not select database.");
		}
	
		function __destruct() {	
			if ($this->db_conn) {
				mysql_close($this->db_conn);
				$this->db_conn = null;
			}
		}
		
		
		/**
		 * Helper method to get a string description for an HTTP status code
		 * http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
		 * @returns status
		 */
		function getStatusCodeMessage($status) {
			
			$codes = Array(
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

			return (isset($codes[$status])) ? $codes[$status] : '';
		}
		
		
		/**
		 * Helper method to send a HTTP response code/message
		 * @returns body
		 */
		function sendResponse($status=200, $body='', $content_type='text/html') {
			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			header($status_header);
			header("Content-type: ". $content_type);
			echo $body;
		}
	    
		
		function submitRandomChallenge($user_id, $subject, $img_url) {
			$challenge_arr = array();
			
			if ($subject == "")
				$subject = "N/A";
			
			$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject .'";';
			$result = mysql_query($query);
			
			if ($result) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblChallengeSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
			}
			
			$rndUser_id = $user_id;
			while ($rndUser_id == $user_id) {
				$range_result = mysql_query(" SELECT MAX(`id`) AS max_id , MIN(`id`) AS min_id FROM `tblUsers`");
				$range_row = mysql_fetch_object($range_result); 
				$rndUser_id = mt_rand($range_row->min_id , $range_row->max_id);
			}
			
			$query = 'SELECT `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$points = mysql_fetch_object(mysql_query($query))->points;
			$query = 'UPDATE `tblUsers` SET `points` = "'. ($points + 1) .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			$query = 'INSERT INTO `tblChallenges` (';
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `img_url`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "0000-00-00 00:00:00", NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			$query = 'INSERT INTO `tblChallengeParticipants` (';
			$query .= '`challenge_id`, `user_id`) ';
			$query .= 'VALUES ("'. $challenge_id .'", "'. $rndUser_id .'");';
			$result = mysql_query($query);
		 			
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"creator_id" => $row->creator_id, 
				"img_url" => $row->img_url,
				"added" => $row->added
			);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		
		function getChallengesForUser($user_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `creator_id` = '. $user_id .';';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => "Waiting", 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title,
					"img_url" => $challenge_row['img_url'], 
					"started" => $challenge_row['started']
				));	
			}
				
			
			$query = 'SELECT * FROM `tblChallenges` INNER JOIN `tblChallengeParticipants` ON `tblChallenges`.`id` = `tblChallengeParticipants`.`challenge_id` WHERE `tblChallengeParticipants`.`user_id` = '. $user_id .';';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
												
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => "Accept", 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title,
					"img_url" => $challenge_row['img_url'], 
					"started" => $challenge_row['started']
				));
			}
			
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function acceptChallenge($user_id, $challenge_id, $img_url) {
			$challenge_arr = array();
			
			$query = 'INSERT INTO `tblChallengeImages` (';
			$query .= '`id`, `challenge_id`, `user_id`, `url`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $img_url .'", NOW();';
			$result = mysql_query($query);
			$img_id = mysql_insert_id();			
			
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function getActiveVotes($user_id) {
			$challenge_arr = array();
			
			$query = 'SELECT `challenge_id` FROM `tblChallengeParticipants` WHERE `user_id` = '. $user_id .';';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $row['challenge_id'] .';';
				$challenge_result = mysql_query($query);
				$challenge_obj = mysql_fetch_object($challenge_result);
				
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
												
				array_push($challenge_arr, array(
					"id" => $challenge_obj->id, 
					"status" => "Started", 
					"creator_id" => $challenge_obj->creator_id, 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title,
					"img_url" => $challenge_obj->img_url, 
					"started" => $challenge_obj->started
				));
			}
			
			
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
	    
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$challenges = new Challenges;
	////$challenges->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']))
					$challenges->submitRandomChallenge($_POST['userID'], $_POST['subject'], $_POST['imgURL']);
				break;
				
			case "2":
				if (isset($_POST['userID']))
					$challenges->getChallengesForUser($_POST['userID']);
				break;
				
			case "3":
				if (isset($_POST['userID']) && isset($_POST['challengeID']))
					$challenges->getChallengesForUser($_POST['userID'], $_POST['challengeID']);
				break;
				
			case "4":
				if (isset($_POST['userID']) && isset($_POST['challengeID']) && isset($_POST['imgURL']))
					$challenges->acceptChallenge($_POST['userID'], $_POST['challengeID'], $_POST['imgURL']);
				break;
				
			case "5":
				if (isset($_POST['userID']))
					$challenges->getActiveVotes($_POST['userID']);
				break;
    	}
	}
?>