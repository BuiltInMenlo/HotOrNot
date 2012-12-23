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
				
		function sendResponse($status=200, $body='', $content_type='text/html') {			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			
			header($status_header);
			header("Content-type: ". $content_type);
			
			echo ($body);
		}
		
		function calcChallengeScores($challenge_id, $creator_id) {
			$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
			$score_result = mysql_query($query);
			
			$score_arr = array('creator' => 0, 'challenger' => 0);
			while ($score_row = mysql_fetch_array($score_result, MYSQL_BOTH)) {										
				if ($score_row['challenger_id'] == $creator_id)
					$score_arr['creator']++;
				
				else
					$score_arr['challenger']++;					
			}
			
			return ($score_arr);
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
		
		
		function getActiveChallengeVotesByActivity($user_id) {
			$challenge_arr = array();			
			$id_arr = array();
			
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 2 OR `status_id` = 4;';
			$result = mysql_query($query);
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$id_arr[$row['id']] = 0;
			}

			$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id` WHERE `tblChallenges`.`status_id` = 2 OR `tblChallenges`.`status_id` = 4;';
			$result = mysql_query($query);
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$id_arr[$row['id']]++;
			}
            
			$cnt = 0;
			arsort($id_arr);
			foreach ($id_arr as $key => $val) {
				if ($cnt == 100)
					break;
								
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $key .';';
				$row = mysql_fetch_array(mysql_query($query), MYSQL_BOTH);
				
				$creator_id = $row['creator_id'];				
				$challenger_id = $row['challenger_id'];
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['challenger_id'] .';';
				$challenger_obj = mysql_fetch_object(mysql_query($query));
								
				array_push($challenge_arr, array(
					"id" => $row['id'], 
					"status" => $row['status_id'], 
					"creator_id" => $row['creator_id'], 
					"creator" => $user_obj->username, 
					"creator_fb" => $user_obj->fb_id, 
					"subject" => $sub_obj->title,
					"creator_img" => $row['creator_img'], 
					"challenger_id" => $row['challenger_id'], 
					"challenger" => $challenger_obj->username, 
					"challenger_fb" => $challenger_obj->fb_id, 
					"challenger_img" => $row['challenger_img'], 
					"score" => $this->calcChallengeScores($key, $creator_id),  
					"started" => $row['started'], 
					"added" => $row['added']
				));
				
				$cnt++;
			}
			
						
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getActiveChallengeVotesByDate($user_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 2 OR `status_id` = 4 ORDER BY `added` DESC LIMIT 100;';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$creator_id = $row['creator_id'];
				$challenger_id = $row['challenger_id'];
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['challenger_id'] .';';
				$challenger_obj = mysql_fetch_object(mysql_query($query));
				
				array_push($challenge_arr, array(
					"id" => $row['id'], 
					"status" => $row['status_id'],
					"creator_id" => $row['creator_id'], 
					"creator" => $user_obj->username,
					"creator_fb" => $user_obj->fb_id,  
					"subject" => $sub_obj->title,
					"creator_img" => $row['creator_img'], 
					"challenger_id" => $row['challenger_id'], 
					"challenger" => $challenger_obj->username, 
					"challenger_fb" => $challenger_obj->fb_id, 
					"challenger_img" => $row['challenger_img'], 
					"score" => $this->calcChallengeScores($row['id'], $creator_id), 
					"started" => $row['started'], 
					"added" => $row['added']
				));
			}
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getActiveChallengeVotesForSubject($user_id, $subject_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE (`status_id` = 2 OR `status_id` = 4) AND `subject_id` = '. $subject_id .' ORDER BY `started` DESC;';
			$result = mysql_query($query);
			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				$creator_id = $row['creator_id'];
				$challenger_id = $row['challenger_id'];
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row['subject_id'] .';';
				$sub_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['creator_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $row['challenger_id'] .';';
				$challenger_obj = mysql_fetch_object(mysql_query($query));				
				
				array_push($challenge_arr, array(
					"id" => $row['id'], 
					"status" => $row['status_id'],
					"creator_id" => $row['creator_id'], 
					"creator" => $user_obj->username,
					"creator_fb" => $user_obj->fb_id,  
					"subject" => $sub_obj->title,
					"creator_img" => $row['creator_img'], 
					"challenger_id" => $row['challenger_id'], 
					"challenger" => $challenger_obj->username, 
					"challenger_fb" => $challenger_obj->fb_id,
					"challenger_img" => $row['challenger_img'], 
					"score" => $this->calcChallengeScores($row['id'], $creator_id), 
					"started" => $row['started'], 
					"added" => $row['added']
				));
			}
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getActiveChallengeVotesForChallenge($user_id, $challenge_id) {
			$challenge_arr = array();
			
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));			
			$creator_id = $challenge_obj->creator_id;
			$challenger_id = $challenge_obj->challenger_id;
			
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$sub_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $creator_id .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `fb_id`, `username` FROM `tblUsers` WHERE `id` = '. $challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			
			array_push($challenge_arr, array(
				"id" => $challenge_id, 
				"status" => $challenge_obj->status_id, 
				"creator_id" => $creator_id, 
				"creator" => $user_obj->username, 
				"creator_fb" => $user_obj->fb_id, 
				"subject" => $sub_obj->title,
				"creator_img" => $challenge_obj->creator_img, 
				"challenger_id" => $challenger_id, 
				"challenger" => $challenger_obj->username, 
				"challenger_fb" => $challenger_obj->fb_id, 
				"challenger_img" => $challenge_obj->challenger_img, 
				"score" => $this->calcChallengeScores($challenge_id, $creator_id), 
				"started" => $challenge_obj->started, 
				"added" => $challenge_obj->added
			));
			
			$this->sendResponse(200, json_encode($challenge_arr));
			return (true);
		}
		
		function getVotersForChallenge($challenge_id) {
			$user_arr = array();
			
			$query = 'SELECT `user_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' LIMIT 100;';
			$challenge_result = mysql_query($query);
			
			while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {								
				$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_row['user_id'] .';';
				$user_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $user_obj->id .' OR `challenger_id` = '. $user_obj->id .';';
				$challenge_tot = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_obj->id .';';
				$points = mysql_num_rows(mysql_query($query));
				
				array_push($user_arr, array(
					"id" => $user_obj->id, 
					"fb_id" => $user_obj->fb_id, 
					"username" => $user_obj->username, 					
					"img_url" => "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square",   
					"points" => $user_obj->points + $points,
					"challenges" => $challenge_tot
				));	
			}
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function upvoteChallenge($challenge_id, $user_id, $isCreator) {
		    $query = 'SELECT `creator_id`, `subject_id`, `challenger_id` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			$creator_id = $challenge_obj->creator_id;
			$challenger_id = $challenge_obj->challenger_id;
						
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$sub_name = mysql_fetch_object(mysql_query($query))->title;
			
			if ($isCreator == "Y")
				$winningUser_id = $creator_id;
								
			else
				$winningUser_id = $challenger_id;
							    
			
			$query = 'INSERT INTO `tblChallengeVotes` (';
			$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';				
			$result = mysql_query($query);
			$vote_id = mysql_insert_id();
						
			$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
			$result = mysql_query($query);
			
			$score_arr = array('creator' => 0, 'challenger' => 0);			
			while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
				if ($row['challenger_id'] == $creator_id)
					$score_arr['creator']++;
					
				else
					$score_arr['challenger']++;
			}
			
			if ($winningUser_id == $creator_id && ($score_arr['creator'] == 10 || $score_arr['creator'] == 20 || $score_arr['creator'] == 30)) {
				$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
				$device_token = mysql_fetch_object(mysql_query($query))->device_token;
				
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "Your '. $sub_name .' challenge has received '. $score_arr[0] .' upvotes!", "sound": "push_01.caf"}}');
			}
			
			if ($winningUser_id == $challenger_id && ($score_arr['challenger'] == 10 || $score_arr['challenger'] == 20 || $score_arr['challenger'] == 30)) {
				$query = 'SELECT `device_token` FROM `tblUsers` WHERE `id` = '. $winningUser_id .';';
				$device_token = mysql_fetch_object(mysql_query($query))->device_token;
				
				$this->sendPush('{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "Your '. $sub_name .' challenge has received '. $score_arr[1] .' upvotes!", "sound": "push_01.caf"}}');
			}
						
			$this->sendResponse(200, json_encode(array(
				"challenge_id" => $challenge_id,
				"user_id" => $winningUser_id, 
				"score" => $score_arr,
				"creator" => $creator_id,				
				"challenger" => $challenger_id, 
				"winner" => $winningUser_id				
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
	
	$votes = new Votes;
	//$votes->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":				
				if (isset($_POST['userID']))
					$votes->getActiveChallengeVotesByActivity($_POST['userID']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['subjectID']))
					$votes->getActiveChallengeVotesForSubject($_POST['userID'], $_POST['subjectID']);
				break;
							
			case "3":
				if (isset($_POST['userID']) && isset($_POST['challengeID']))
					$votes->getActiveChallengeVotesForChallenge($_POST['userID'], $_POST['challengeID']);
				break;
				
			case "4":
				if (isset($_POST['userID']))
					$votes->getActiveChallengeVotesByDate($_POST['userID']);
				break;
				
			case "5":
				if (isset($_POST['challengeID']))
					$votes->getVotersForChallenge($_POST['challengeID']);
				break;
				
			case "6":
				if (isset($_POST['challengeID']) && isset($_POST['userID']) && isset($_POST['creator']))
					$votes->upvoteChallenge($_POST['challengeID'], $_POST['userID'], $_POST['creator']);
				break;
    	}
	}
?>