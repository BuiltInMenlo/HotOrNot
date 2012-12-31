<?php

	class Users {
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
		
		function userObject($user_id) {
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = "'. $user_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_id .';';
			$votes = mysql_num_rows(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_id .';';
			$pokes = mysql_num_rows(mysql_query($query));
			
			return(array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"fb_id" => $row->fb_id, 
				"gender" => $row->gender, 
				"paid" => $row->paid,
				"points" => $row->points, 
				"votes" => $votes, 
				"pokes" => $pokes, 
				"notifications" => $row->notifications
			));
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
		
		
		function submitNewUser($device_token) {
			$query = 'SELECT * FROM `tblUsers` WHERE `device_token` = "'. $device_token .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_object($result);
				$user_id = $row->id;
				
				$query = 'UPDATE `tblUsers` SET `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);				
				
			} else {				
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `username`, `device_token`, `fb_id`, `gender`, `paid`, `points`, `notifications`, `last_login`, `added`) ';
				$query .= 'VALUES (NULL, "", "'. $device_token .'", "", "N", "N", "0", "Y", CURRENT_TIMESTAMP, NOW());';
				$result = mysql_query($query);
				$user_id = mysql_insert_id();
				
				$query = 'UPDATE `tblUsers` SET `username` = "PicChallenge'. $user_id .'" WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);																
			}
			
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$row = mysql_fetch_object(mysql_query($query));
			
	   		$user_arr = array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"fb_id" => $row->fb_id, 
				"paid" => $row->paid, 
				"points" => $row->points, 
				"votes" => 0,
				"pokes" => 0, 
				"notifications" => $row->notifications
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
		}
		
		
		function updateName($user_id, $username, $fb_id, $gender) {
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
			if (mysql_num_rows(mysql_query($query)) > 0) {
				$invite_id = mysql_fetch_object(mysql_query($query))->id;
				
				$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 7 AND `challenger_id` = '. $invite_id .';';
				$invite_result = mysql_query($query);
				
				while ($challenge_row = mysql_fetch_array($invite_result, MYSQL_BOTH)) {
					$query = 'UPDATE `tblChallenges` SET `status_id` = 2, `challenger_id` = "'. $user_id .'" WHERE `id` = '. $challenge_row['id'] .';';
					$result = mysql_query($query);
				}
			}
			
			$user_arr = $this->userObject($user_id);
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function updatePaid($user_id, $isPaid) {
			$query = 'UPDATE `tblUsers` SET `paid` = "'. $isPaid .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
					   
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function getUser($user_id) {
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function updateNotifications($user_id, $isNotifications) {
			$user_arr = array();
			
			$query = 'UPDATE `tblUsers` SET `notifications` = "'. $isNotifications .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function pokeUser($poker_id, $pokee_id) {
			$query = 'INSERT INTO `tblUserPokes` (';
			$query .= '`id`, `user_id`, `poker_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $pokee_id .'", "'. $poker_id .'", NOW());';
			$result = mysql_query($query);
			$poke_id = mysql_insert_id();
			
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $poker_id .';';
			$poker_name = mysql_fetch_object(mysql_query($query))->username;
			
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $pokee_id .';';
			$pokee_obj = mysql_fetch_object(mysql_query($query));			
			
			if ($pokee_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $pokee_obj->device_token .'"], "type":"2", "aps": {"alert": "'. $poker_name .' has poked you!", "sound": "push_01.caf"}}');
			
			$this->sendResponse(200, json_encode(array(
				"id" => $poke_id
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
	
	$users = new Users;
	////$users->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['token']))
					$users->submitNewUser($_POST['token']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender']))
					$users->updateName($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
				break;
			
			case "3":
				if (isset($_POST['userID']) && isset($_POST['isPaid']))
					$users->updatePaid($_POST['userID'], $_POST['isPaid']);
				break;
				
			case "4":
				if (isset($_POST['userID']) && isset($_POST['isNotifications']))
					$users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
				break;
				
			case "5":
				if (isset($_POST['userID']))
					$users->getUser($_POST['userID']);
				break;
				
			case "6":
				if (isset($_POST['pokerID']) && isset($_POST['pokeeID']))
					$users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
				break;
    	}
	}
?>