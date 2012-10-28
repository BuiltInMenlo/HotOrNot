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
				$range_result = mysql_query("SELECT MAX(`id`) AS max_id, MIN(`id`) AS min_id, `username` FROM `tblUsers`");
				$range_row = mysql_fetch_object($range_result); 
				$rndUser_id = mt_rand(2, $range_row->max_id);
				
				if (mysql_num_rows(mysql_query('SELECT `id` FROM `tblUsers` WHERE `id` = '. $rndUser_id .';')) == 0)
					$rndUser_id = $user_id;
					
				if (substr($range_row->username, 0, 12) == "PicChallenge")
					$rndUser_id = $user_id;				   
			}
			
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $rndUser_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			$device_token = $challenger_obj->device_token;
			$isPush = ($challenger_obj->notifications == "Y");
			
			$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));
			$fb_id = $creator_obj->fb_id;
			$points = $creator_obj->points;			
			
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
			
			if ($isPush) {
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
			    curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch);
			}		
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"creator_id" => $user_id, 
				"creator" => $creator_obj->username, 
				"creator_fb" => $fb_id, 				
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
		
		function submitFriendChallenge($user_id, $subject, $img_url, $fb_id, $fb_name) {
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
			
			$query = 'SELECT `id`, `device_token`, `notifications` FROM `tblUsers` WHERE `fb_id` = '. $fb_id .';';
			
			if (mysql_num_rows(mysql_query($query)) > 0) {			
				$challenger_obj = mysql_fetch_object(mysql_query($query));
				$challenger_id = $challenger_obj->id;
				$device_token = $challenger_obj->device_token;
				$isPush = ($challenger_obj->notifications == "Y");
						
				$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
				$creator_obj = mysql_fetch_object(mysql_query($query));
				$fb_id = $creator_obj->fb_id;
				$points = $creator_obj->points;
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
				
				if ($isPush) {
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
					curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
					//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
					curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					curl_setopt($ch, CURLOPT_POST, 1);
					curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
				 	$res = curl_exec($ch);
					$err_no = curl_errno($ch);
					$err_msg = curl_error($ch);
					$header = curl_getinfo($ch);
					curl_close($ch);
				}
		 			
			
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
				$row = mysql_fetch_object(mysql_query($query));
			
				$challenge_arr = array(
					"id" => $row->id, 
					"status" => "Waiting", 
					"subject" => $subject, 
					"creator_id" => $row->creator_id, 
					"creator" => $creator_obj->username, 
					"creator_fb" => $fb_id, 
					"challenger_id" => $challenger_id, 
					"challenger" => $fb_name,
					"img_url" => $row->img_url,  
					"img2_url" => "", 
					"score1" => 1,
					"score2" => 1, 
					"started" => $row->started, 
					"added" => $row->added
				);
			
			} else {
				$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
				if (mysql_num_rows(mysql_query($query)) == 0) {				
					$query = 'INSERT INTO `tblInvitedUsers` (';
					$query .= '`id`, `fb_id`, `username`, `added`) ';
					$query .= 'VALUES (NULL, "'. $fb_id .'", "'. $fb_name .'", NOW());';
					$result = mysql_query($query);
					$challenger_id = mysql_insert_id();
				
				} else 
					$challenger_id = mysql_fetch_object(mysql_query($query))->id;
				
				$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $user_id .';';
				$creator_obj = mysql_fetch_object(mysql_query($query));
								
				$query = 'INSERT INTO `tblChallenges` (';
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `img_url`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "7", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "0000-00-00 00:00:00", NOW());';
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
					"status" => $row->status_id, 
					"subject" => $subject, 
					"creator_id" => $row->creator_id, 
					"creator" => $creator_obj->username, 
					"creator_fb" => $creator_obj->fb_id, 
					"challenger_id" => $challenger_id, 
					"challenger" => $fb_name,
					"img_url" => $row->img_url,  
					"img2_url" => "", 
					"score1" => 1,
					"score2" => 1, 
					"started" => $row->started, 
					"added" => $row->added
				);
				
			}
			
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
			
						
			$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));
			$fb_id = $creator_obj->fb_id;
			$points = $creator_obj->points;
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
			
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			$device_token = $challenger_obj->device_token; 
			$isPush = ($challenger_obj->notifications == "Y");
			
			if ($isPush) {
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
				curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch);		
			}
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"creator_id" => $row->creator_id, 
				"creator" => "", 
				"creator_fb" => $fb_id, 
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
			
			$query = 'SELECT * FROM `tblChallenges` INNER JOIN `tblChallengeParticipants` ON `tblChallenges`.`id` = `tblChallengeParticipants`.`challenge_id` WHERE `tblChallenges`.`status_id` != 3 AND (`tblChallenges`.`creator_id` = '. $user_id .' OR `tblChallengeParticipants`.`user_id` = '. $user_id .') ORDER BY `tblChallenges`.`added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				if ($challenge_row['status_id'] != "7")
					$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
					
				else
					$query = 'SELECT `username` FROM `tblInvitedUsers` WHERE `id` = '. $challenger_id .';';
				
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenge_row['creator_id'] .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				if ($challenger_id == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "1";
				
				if ($challenge_row['started'] != "0000-00-00 00:00:00") {
					$now_date = date('Y-m-d H:i:s', time());					
					$end_date = date('Y-m-d H:i:s', strtotime($challenge_row['started'] .' + 2 hours'));				   

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
					"creator_fb" => $user_obj->fb_id, 
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
		
		function getChallengesForUserBeforeDate($user_id, $date) {
			$challenge_arr = array();			
			
			$query = 'SELECT * FROM `tblChallenges` INNER JOIN `tblChallengeParticipants` ON `tblChallenges`.`id` = `tblChallengeParticipants`.`challenge_id` WHERE `tblChallenges`.`status_id` != 3 AND `tblChallenges`.`added` < "'. $date .'" AND (`tblChallenges`.`creator_id` = '. $user_id .' OR `tblChallengeParticipants`.`user_id` = '. $user_id .') ORDER BY `tblChallenges`.`added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				if ($challenge_row['status_id'] != "7")
					$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
					
				else
					$query = 'SELECT `username` FROM `tblInvitedUsers` WHERE `id` = '. $challenger_id .';';
					
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenge_row['creator_id'] .';';
				$score1 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .' AND `challenger_id` = '. $challenger_id .';';
				$score2 = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$img_obj = mysql_fetch_object(mysql_query($query));
				
				if ($challenger_id == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "1";
				
				if ($challenge_row['started'] != "0000-00-00 00:00:00") {
					$now_date = date('Y-m-d H:i:s', time());					
					$end_date = date('Y-m-d H:i:s', strtotime($challenge_row['started'] .' + 2 hours'));				   

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
					"creator_fb" => $user_obj->fb_id, 
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
						
			
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$challenger_name = mysql_fetch_object(mysql_query($query))->username; 
			
			$query = 'SELECT `subject_id`, `creator_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject_name = mysql_fetch_object(mysql_query($query))->title;
						
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';			
			$creator_obj = mysql_fetch_object(mysql_query($query));
			$device_token = $creator_obj->device_token;
			$isPush = ($creator_obj->notifications == "Y");
			
			if ($isPush) { 			
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
				curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $challenger_name .' has accepted your #'. $subject_name .' challenge!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch); 
			}   		
			
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);			
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id,
				"img_id" => $img_id, 
				"img_url" => $img_url
			)));
			return (true);	
		}
		
		function getActiveVotesByActivity($user_id) {
			$challenge_arr = array();			
			$id_arr = array();
			
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4;';
			$result = mysql_query($query);
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$id_arr[$row['id']] = 0;
			}

			$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id` WHERE `tblChallenges`.`status_id` = 4;';
			$result = mysql_query($query);
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$id_arr[$row['id']]++;
			}

			arsort($id_arr);
			foreach ($id_arr as $key => $val) {				
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $key .';';
				$row = mysql_fetch_array(mysql_query($query), MYSQL_BOTH);
				
				$creator_id = $row['creator_id'];
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
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
					"creator_fb" => $user_obj->fb_id, 
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
		
		function getActiveVotesByDate($user_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 4 ORDER BY `started` DESC;';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$creator_id = $row['creator_id'];
				
				$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $row['id'] .';';
				$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
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
					"creator_fb" => $user_obj->fb_id,  
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
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
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
					"creator_fb" => $user_obj->fb_id,  
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
		
		function getActiveVotesForChallenge($user_id, $challenge_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));			
			$creator_id = $challenge_obj->creator_id;
			
			$query = 'SELECT `user_id` FROM `tblChallengeParticipants` WHERE `challenge_id` = '. $challenge_id .';';
			$challenger_id = mysql_fetch_object(mysql_query($query))->user_id;
			
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$sub_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $creator_id .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_id .';';
			$img_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `id` 
			FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `challenger_id` = '. $creator_id .';';
			$score1 = mysql_num_rows(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `challenger_id` = '. $challenger_id .';';
			$score2 = mysql_num_rows(mysql_query($query));
											
			array_push($challenge_arr, array(
				"id" => $challenge_id, 
				"status" => "Started", 
				"creator_id" => $creator_id, 
				"creator" => $user_obj->username, 
				"creator_fb" => $user_obj->fb_id, 
				"subject" => $sub_obj->title,
				"img_url" => $challenge_obj->img_url,
				"img2_url" => $img_obj->url,
				"score1" => $score1,
				"score2" => $score2, 
				"started" => $challenge_obj->started, 
				"added" => $challenge_obj->added
			));
			
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
						
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
			$result = mysql_query($query);
			
			$points1 = 0;
			$points2 = 0;
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				if ($row['challenger_id'] == $creator_id)
					$points1++;
					
				else
					$points2++;
			}
						
			$this->sendResponse(200, json_encode(array(
				"challenge_id" => $challenge_id,
				"user_id" => $winningUser_id, 
				"points1" => $points1, 
				"points2" => $points2, 
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
			
			$to = "bim.picchallenge@gmail.com";
			$subject = "Flagged Challenge";
			$body = "Challenge ID: #". $challenge_id ."\nFlagged By User: #". $user_id;
			$from = "picchallenge@builtinmenlo.com";
			$headers = "From:picchallenge@builtinmenlo.com";
			if (mail($to, $subject, $body, $headers)) 
			   $mail_res = true;

			else
			   $mail_res = false;  
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id,
				"mail" => $mail_res
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
					$challenges->getActiveVotesByActivity($_POST['userID']);
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
					$challenges->submitFriendChallenge($_POST['userID'], $_POST['subject'], $_POST['imgURL'], $_POST['fbID'], $_POST['fbName']);
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
				
			case "12":
				if (isset($_POST['userID']) && isset($_POST['datetime']))
					$challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['datetime']);
				break;
			
			case "13":
				if (isset($_POST['userID']) && isset($_POST['challengeID']))
					$challenges->getActiveVotesForChallenge($_POST['userID'], $_POST['challengeID']);
				break;
				
			case "14":
				if (isset($_POST['userID']))
					$challenges->getActiveVotesByDate($_POST['userID']);
				break;
    	}
	}
?>