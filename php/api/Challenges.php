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
			
			if (mysql_num_rows($result) > 0) {
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
				$range_result = mysql_query("SELECT MAX(`id`) AS max_id, MIN(`id`) AS min_id FROM `tblUsers`");
				$range_row = mysql_fetch_object($range_result); 
				$rndUser_id = mt_rand(2, $range_row->max_id);
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
				"creator" => "", 				
				"challenger_id" => $rndUser_id, 
				"challenger" => "",
				"img_url" => $row->img_url,  
				"img2_url" => "", 
				"score1" => 1,
				"score2" => 1, 
				"started" => $row->started, 
				"added" => $row->added
			);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function submitFriendChallenge($user_id, $subject, $img_url, $fb_id) {
			$challenge_arr = array();
			
			if ($subject == "")
				$subject = "N/A";
			
			$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblChallengeSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
			}
			
			$query = 'SELECT `id` FROM `tblUsers` WHERE `fb_id` = '. $fb_id .';';
			$rndUser_id = mysql_fetch_object(mysql_query($query))->id;
			
						
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
				"creator" => "", 
				"challenger_id" => $rndUser_id, 
				"challenger" => "",
				"img_url" => $row->img_url,  
				"img2_url" => "", 
				"score1" => 1,
				"score2" => 1, 
				"started" => $row->started, 
				"added" => $row->added
			);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function submitChallengeWithChallenger($user_id, $subject, $img_url, $challenger_id) {
			$challenge_arr = array();
			
			if ($subject == "")
				$subject = "N/A";
			
			$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblChallengeSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
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
			$query .= 'VALUES ("'. $challenge_id .'", "'. $challenger_id .'");';
			$result = mysql_query($query);
		 			
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"creator_id" => $row->creator_id, 
				"creator" => "", 
				"challenger_id" => $challenger_id, 
				"challenger" => "",
				"img_url" => $row->img_url,  
				"img2_url" => "", 
				"score1" => 1,
				"score2" => 1, 
				"started" => $row->started, 
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
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $user_id .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				if ($challenge_row['started'] != "0000-00-00 00:00:00") {
					$now_date = date('Y-m-d H:i:s', time());					
					$end_date = date('Y-m-d H:i:s', strtotime($challenge_row['started'] .' + 8 hours'));				   

					if ($now_date > $end_date) {
						$challenge_row['status_id'] = "5";
						
						$query = 'UPDATE `tblChallenges` SET `status_id` = 5 WHERE `id` = '. $challenge_row['id'] .';';
						$result = mysql_query($query);									
					}
				}
				
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => $challenge_row['status_id'], 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title, 
					"challenger_id" => $challenger_id, 
					"challenger" => $challenger_name, 
					"img_url" => $challenge_row['img_url'],   
					"img2_url" => $img_obj->url,
					"score1" => $score1,
					"score2" => $score2,
					"started" => $challenge_row['started'],
					"added" => $challenge_row['added']
				));	
			}
			
			
			$query = 'SELECT * FROM `tblChallenges` INNER JOIN `tblChallengeParticipants` ON `tblChallenges`.`id` = `tblChallengeParticipants`.`challenge_id` WHERE `tblChallengeParticipants`.`user_id` = '. $user_id .';';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $user_id .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				if ($challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "1";
					
				if ($challenge_row['started'] != "0000-00-00 00:00:00") {
				$now_date = date('Y-m-d H:i:s', time());					
				$end_date = date('Y-m-d H:i:s', strtotime($challenge_row['started'] .' + 8 hours'));				   

				if ($now_date > $end_date) {
					$challenge_row['status_id'] = "5";
					
					$query = 'UPDATE `tblChallenges` SET `status_id` = 5 WHERE `id` = '. $challenge_row['id'] .';';
					$result = mysql_query($query);									
				}
			}
												
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => $challenge_row['status_id'], 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title, 
					"challenger_id" => $challenger_id, 
					"challenger" => $challenger_name, 
					"img_url" => $challenge_row['img_url'], 
					"img2_url" => $img_obj->url, 
					"score1" => $score1,
					"score2" => $score2,
					"started" => $challenge_row['started'], 
					"added" => $challenge_row['added']
				));
			}
			
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function acceptChallenge($user_id, $challenge_id, $img_url) {
			$challenge_arr = array();
			
			$query = 'INSERT INTO `tblChallengeImages` (';
			$query .= '`id`, `challenge_id`, `user_id`, `url`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $img_url .'", NOW());';
			$result = mysql_query($query);
			$img_id = mysql_insert_id();			
			
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);			
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id,
				"img_id" => $img_id, 
				"img_url" => $img_url
			)));
			return (true);	
		}
		
		function getActiveVotes($user_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 4 ORDER BY `started` DESC;';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$creator_id = $row['creator_id'];
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $row['id'] .' AND `challenger_id` = '. $creator_id .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
												
				array_push($challenge_arr, array(
					"id" => $row['id'], 
					"status" => "Started", 
					"creator_id" => $row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title,
					"img_url" => $row['img_url'],
					"img2_url" => $img_obj->url, 
					"score1" => $score1,
					"score2" => $score2,
					"started" => $row['started'], 
					"added" => $row['added']
				));
			}
			
						
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getActiveVotesForSubject($user_id, $subject_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 4 AND `subject_id` = '. $subject_id .' ORDER BY `started` DESC;';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$creator_id = $row['creator_id'];
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $row['id'] .' AND `challenger_id` = '. $creator_id .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
												
				array_push($challenge_arr, array(
					"id" => $row['id'], 
					"status" => "Started", 
					"creator_id" => $row['creator_id'], 
					"creator" => $user_obj->username, 
					"subject" => $sub_obj->title,
					"img_url" => $row['img_url'],
					"img2_url" => $img_obj->url,
					"score1" => $score1,
					"score2" => $score2, 
					"started" => $row['started'], 
					"added" => $row['added']
				));
			}
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function upvoteChallenge($challenge_id, $user_id, $isCreator) {
		    $query = 'SELECT `creator_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$creator_id = mysql_fetch_object(mysql_query($query))->creator_id;
			
			$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_id .';';
			$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
			
			if ($isCreator == "Y")
				$winningUser_id = $creator_id;
								
			else
				$winningUser_id = $challenger_id;
							    
			
			$query = 'INSERT INTO `tblChallengeVotes` (';
			$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';				
			$result = mysql_query($query);
			$vote_id = mysql_insert_id();
			
			
			$query = 'SELECT `points` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
			$points = mysql_fetch_object(mysql_query($query))->points;
			
			$query = 'UPDATE `tblUsers` SET `points` = "'. (++$points) .'" WHERE `id` = '. $winningUser_id .';';
			$result = mysql_query($query);
			
			
			$this->sendResponse(200, json_encode(array(
				"challenge_id" => $challenge_id,
				"user_id" => $winningUser_id, 
				"points" => $points, 
				"creator" => $winningUser_id				
			)));
			return (true);
		}
		
		function cancelChallenge ($challenge_id) {
			$query = 'UPDATE `tblChallenges` SET `status_id` = 3 WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);			
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id
			)));
			return (true);
		}
		
		function flagChallenge ($user_id, $challenge_id) {
			$query = 'UPDATE `tblChallenges` SET `status_id` = 6 WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);
			
			$query = 'INSERT INTO `tblFlaggedChallenges` (';
			$query .= '`challenge_id`, `user_id`, `added`) VALUES (';
			$query .= '"'. $challenge_id .'", "'. $user_id .'", NOW());';				
			$result = mysql_query($query);		   
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id
			)));
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
				
			case "6":
				if (isset($_POST['challengeID']) && isset($_POST['userID']) && isset($_POST['creator']))
					$challenges->upvoteChallenge($_POST['challengeID'], $_POST['userID'], $_POST['creator']);
				break;
				
			case "7":
				if (isset($_POST['userID']) && isset($_POST['subjectID']))
					$challenges->getActiveVotesForSubject($_POST['userID'], $_POST['subjectID']);
				break;
				
			case "8":
				if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['fbID']))
					$challenges->submitFriendChallenge($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['fbID']);
				break;
				
			case "9":
				if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURL']) && isset($_POST['challengerID']))
					$challenges->submitChallengeWithChallenger($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['challengerID']);
				break;
				
			case "10":
				if (isset($_POST['challengeID']))
					$challenges->cancelChallenge($_POST['challengeID']);
				break;
				
			case "11":
				if (isset($_POST['userID']) && isset($_POST['challengeID']))
					$challenges->flagChallenge($_POST['userID'], $_POST['challengeID']);
				break;
    	}
	}
?>