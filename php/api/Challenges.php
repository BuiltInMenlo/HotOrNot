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
				
		function sendResponse($status=200, $body='', $content_type='text/html') {			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			
			header($status_header);
			header("Content-type: ". $content_type);
			
			echo ($body);
		}
		
		function submitSubject($user_id, $subject_name) {
			if ($subject_name == "")
				$subject_name = "N/A";
			
			$query = 'SELECT `id` FROM `tblChallengeSubjects` WHERE `title` = "'. $subject_name .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblChallengeSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject_name .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
			}
			
			return ($subject_id);	
		}
		
		function sendPush($msg) {
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
		}
	    
		
		function submitRandomChallenge($user_id, $subject, $img_url) {
			$challenge_arr = array();			
			$subject_id = $this->submitSubject($user_id, $subject);			
			
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
			
			$query = 'SELECT `username`, `fb_id`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $rndUser_id .';';
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
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_url`, `challenger_id`, `challenger_img`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $rndUser_id .'", "", "0000-00-00 00:00:00", NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			if ($isPush)
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
				
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"preview_url" => "",
				"creator_id" => $user_id, 
				"creator" => $creator_obj->username, 
				"creator_fb" => $fb_id, 				
				"challenger_id" => $rndUser_id, 
				"challenger" => "", 
				"challenger_fb" => "", 
				"creator_img" => $row->creator_img,  
				"challenger_img" => $row->challenger_img, 
				"score" => array('creator' => 0, 'challenger' => 0),
				"started" => $row->started, 
				"added" => $row->added
			);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function submitFriendChallenge($user_id, $subject, $img_url, $fb_id, $fb_name) {
			$challenge_arr = array();
			
			$subject_id = $this->submitSubject($user_id, $subject);
			
			$query = 'SELECT `id`, `device_token`, `username`, `fb_id`, `notifications` FROM `tblUsers` WHERE `fb_id` = '. $fb_id .';';			
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
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "0000-00-00 00:00:00", NOW());';
				$result = mysql_query($query);
				$challenge_id = mysql_insert_id();
			    
				
				if ($isPush)
					$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
		 			
			
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
				$row = mysql_fetch_object(mysql_query($query));
				
				
				$challenge_arr = array(
					"id" => $row->id, 
					"status" => "Waiting", 
					"subject" => $subject, 
					"preview_url" => "",
					"creator_id" => $row->creator_id, 
					"creator" => $creator_obj->username, 
					"creator_fb" => $fb_id, 
					"challenger_id" => $challenger_id, 
					"challenger" => $fb_name, 
					"challenger_fb" => $challenger_obj->fb_id, 
					"creator_img" => $row->creator_img,  
					"challenger_img" => "", 
					"score" => array('creator' => 0, 'challenger' => 0),
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
				$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `started`, `added`) ';
				$query .= 'VALUES (NULL, "7", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "0000-00-00 00:00:00", NOW());';
				$result = mysql_query($query);
				$challenge_id = mysql_insert_id();
			   
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
				$row = mysql_fetch_object(mysql_query($query));
			
				$challenge_arr = array(
					"id" => $row->id, 
					"status" => $row->status_id, 
					"subject" => $subject,
					"preview_url" => "", 
					"creator_id" => $row->creator_id, 
					"creator" => $creator_obj->username, 
					"creator_fb" => $creator_obj->fb_id, 
					"challenger_id" => $challenger_id, 
					"challenger" => $fb_name,
					"creator_img" => $row->creator_img,  
					"challenger_img" => "", 
					"score" => array('creator' => 0, 'challenger' => 0),
					"started" => $row->started, 
					"added" => $row->added
				);
				
			}
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function submitChallengeWithChallenger($user_id, $subject, $img_url, $challenger_id) {
			$challenge_arr = array();
			
			$subject_id = $this->submitSubject($user_id, $subject);
						
			$query = 'SELECT `username`, `fb_id`, `points` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));
			$fb_id = $creator_obj->fb_id;
			$points = $creator_obj->points;
			$query = 'UPDATE `tblUsers` SET `points` = "'. ($points + 1) .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			$query = 'INSERT INTO `tblChallenges` (';
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `creator_img`, `challenger_id`, `challenger_img`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "'. $img_url .'", "'. $challenger_id .'", "", "0000-00-00 00:00:00", NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			$query = 'SELECT `device_token`, `username`, `fb_id`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			$device_token = $challenger_obj->device_token; 
			$isPush = ($challenger_obj->notifications == "Y");
			
			if ($isPush)
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_obj->username .' has sent you a #'. $subject .' challenge!", "sound": "push_01.caf"}}');
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $challenge_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$challenge_arr = array(
				"id" => $row->id, 
				"status" => "Waiting", 
				"subject" => $subject, 
				"preview_url" => "",
				"creator_id" => $row->creator_id, 
				"creator" => $creator_obj->username, 
				"creator_fb" => $fb_id, 
				"challenger_id" => $challenger_id, 
				"challenger" => $challenger_obj->username,
				"challenger_fb" => $challenger_obj->fb_id, 
				"creator_img" => $row->creator_img,  
				"challenger_img" => $row->challenger_img, 
				"score" => array('creator' => 0, 'challenger' => 0),
				"started" => $row->started, 
				"added" => $row->added
			);
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getChallengesForUser($user_id) {
			$challenge_arr = array();			
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` != 3 AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$challenger_id = $challenge_row['challenger_id'];
				
				$query = 'SELECT `title`, `itunes_id` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				if ($challenge_row['status_id'] != "7")
					$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
					
				else
					$query = 'SELECT `username`, `fb_id` FROM `tblInvitedUsers` WHERE `id` = '. $challenger_id .';';
				
				$challenger_obj = mysql_fetch_object(mysql_query($query));
				$challenger_name = $challenger_obj->username;
				$challenger_fb = $challenger_obj->fb_id;
				
				$preview_url = "";
				if ($sub_obj->itunes_id != "") {
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, "http://itunes.apple.com/lookup?country=us&id=". $sub_obj->itunes_id);
					curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					$response = curl_exec($ch);
				    curl_close ($ch);    
					$json_arr = json_decode($response, true);
									
					if (count($json_arr['results']) > 0) {
						$json_results = $json_arr['results'][0];
						$preview_url = $json_results['previewUrl'];
					}
				}
				
				$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_row['id'] .';';
				$score_result = mysql_query($query);
				
				$score_arr = array('creator' => 0, 'challenger' => 0);
				while ($score_row = mysql_fetch_array($score_result, MYSQL_BOTH)) {										
					if ($score_row['challenger_id'] == $creator_id)
						$score_arr['creator']++;
					
					else
						$score_arr['challenger']++;					
				}
				
				if ($challenger_id == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "1";
																
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => $challenge_row['status_id'], 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"creator_fb" => $user_obj->fb_id, 
					"subject" => $sub_obj->title, 
					"preview_url" => $preview_url, 
					"challenger_id" => $challenger_id, 
					"challenger" => $challenger_name, 
					"challenger_fb" => $challenger_fb, 
					"creator_img" => $challenge_row['creator_img'], 
					"challenger_img" => $challenge_row['challenger_img'], 
					"score" => $score_arr, 
					"started" => $challenge_row['started'], 
					"added" => $challenge_row['added']
				));
			}
			
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);	
		}
		
		function getChallengesForUserBeforeDate($user_id, $date) {
			$challenge_arr = array();			
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` != 3 AND `added` < "'. $date .'" AND (`creator_id` = '. $user_id .' OR `challenger_id` = '. $user_id .') ORDER BY `added` DESC LIMIT 10;';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
				$challenger_id = $challenge_row['challenger_id'];
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $challenge_row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
								
				if ($challenge_row['status_id'] != "7")
					$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
					
				else
					$query = 'SELECT `username`, `fb_id` FROM `tblInvitedUsers` WHERE `id` = '. $challenger_id .';';
				
				$challenger_obj = mysql_fetch_object(mysql_query($query));
				$challenger_name = $challenger_obj->username;
				$challenger_fb = $challenger_obj->fb_id;
				
				$preview_url = "";
				if ($sub_obj->itunes_id != "") {
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, "http://itunes.apple.com/lookup?country=us&id=". $sub_obj->itunes_id);
					curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					$response = curl_exec($ch);
				    curl_close ($ch);    
					$json_arr = json_decode($response, true);
				
					if (count($json_arr['results']) > 0) {
						$json_results = $json_arr['results'][0];
						$preview_url = $json_results['previewUrl'];
					}
				}
				
				if ($challenger_id == $user_id && $challenge_row['status_id'] == "2")
					$challenge_row['status_id'] = "1";
				
																
				array_push($challenge_arr, array(
					"id" => $challenge_row['id'], 
					"status" => $challenge_row['status_id'], 
					"creator_id" => $challenge_row['creator_id'], 
					"creator" => $user_obj->username, 
					"creator_fb" => $user_obj->fb_id, 
					"subject" => $sub_obj->title, 
					"preview_url" => $preview_url, 
					"challenger_id" => $challenger_id, 
					"challenger" => $challenger_name, 
					"challenger_fb" => $challenger_fb, 
					"creator_img" => $challenge_row['creator_img'], 
					"challenger_img" => $challenge_row['challenger_img'], 
					"started" => $challenge_row['started'], 
					"added" => $challenge_row['added']
				));
			}
			
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function acceptChallenge($user_id, $challenge_id, $img_url) {
			$challenge_arr = array();
			
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
			
			if ($isPush)
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $challenger_name .' has accepted your #'. $subject_name .' challenge!", "sound": "push_01.caf"}}'); 			

			
			$query = 'UPDATE `tblChallenges` SET `status_id` = 4, `challenger_img` = "'. $img_url .'", `started` = NOW() WHERE `id` = '. $challenge_id .';';
			$result = mysql_query($query);			
			
			$this->sendResponse(200, json_encode(array(
				"id" => $challenge_id,
				"img_url" => $img_url
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
				break;
				
			case "6":
				break;
				
			case "7":
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
    	}
	}
?>