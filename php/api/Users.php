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
				
		function sendResponse($status=200, $body='', $content_type='text/json') {			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			
			header($status_header);
			header("Content-type: ". $content_type);
			
			echo ($body);
		}		
		
		/**
		 * Helper function to retrieve a user's info
		 * @param $user_id The ID of the user to get (integer)
		 * @param $meta Any extra info to include (string)
		 * @return An associative object for a user (array)
		**/ 
		function userObject($user_id, $meta="") {
			
			// get user row
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = "'. $user_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			// get total votes
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_id .';';
			$votes = mysql_num_rows(mysql_query($query));
			
			// get total pokes
			$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_id .';';
			$pokes = mysql_num_rows(mysql_query($query));
			
			// get total pics
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $row->id .';';
			$pics = mysql_num_rows(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblChallenges` WHERE `challenger_id` = '. $row->id .' AND `challenger_img` != "";';
			$pics += mysql_num_rows(mysql_query($query));
			
			
			// find the avatar image
			if ($row->img_url == "") {
				if ($row->fb_id == "")
					$avatar_url = "https://s3.amazonaws.com/picchallenge/default_user.jpg";
					
				else
					$avatar_url = "https://graph.facebook.com/". $row->fb_id ."/picture?type=square";
			
			} else
				$avatar_url = $row->img_url;
				
			
			// return
			return(array(
				'id' => $row->id, 
				'username' => $row->username,
				'name' => $row->username, 
				'token' => $row->device_token, 
				'fb_id' => $row->fb_id, 
				'gender' => $row->gender, 
				'avatar_url' => $avatar_url,
				'bio' => $row->bio,
				'website' => $row->website,
				'paid' => $row->paid,
				'points' => $row->points, 
				'votes' => $votes, 
				'pokes' => $pokes, 
				'pics' => $pics,
				'notifications' => $row->notifications, 
				'meta' => $meta
			));
		}
		
		/**
		 * Helper function to send an email to a facebook user
		 * @param $username The facebook username to send to (string)
		 * @param $msg The message body (string)
		 * @return Whether or not the email was sent (boolean)
		**/
		function fbEmail ($username, $msg) {
			// core message
			$to = $username ." <". $username ."@facebook.com>";
			$subject = "Welcome to PicChallengeMe!";
			$from = "PicChallenge <picchallenge@builtinmenlo.com>";
			
			// mail headers
			$headers_arr = array();
			$headers_arr[] = "MIME-Version: 1.0";
			$headers_arr[] = "Content-type: text/plain; charset=iso-8859-1";
			$headers_arr[] = "Content-Transfer-Encoding: 8bit";
			$headers_arr[] = "From: ". $from;
			$headers_arr[] = "Reply-To: ". $from;
			$headers_arr[] = "Subject: ". $subject;
			$headers_arr[] = "X-Mailer: PHP/". phpversion();
			
			// send & return
			return (mail($to, $subject, $msg, implode("\r\n", $headers_arr)));
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
		 * Adds a new user or returns one if it already exists
		 * @param $device_token The Urban Airship token generated on device (string)
		 * @return An associative object representing a user (array)
		**/
		function submitNewUser($device_token) {
			
			// check for user
			$query = 'SELECT * FROM `tblUsers` WHERE `device_token` = "'. $device_token .'";';
			$result = mysql_query($query);
			
			// found the user
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_object($result);
				$user_id = $row->id;
				
				// update last login
				$query = 'UPDATE `tblUsers` SET `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);				
			
			// not found
			} else {
				
				// default names
				$defaultName_arr = array(
					"snap4snap",
					"picchampX",
					"swagluver",
					"coolswagger",
					"yoloswag",
					"tumblrSwag",
					"instachallenger",
					"hotbitchswaglove",
					"lovepeaceswaghot",
					"hotswaglover",
					"snapforsnapper",
					"snaphard",
					"snaphardyo",
					"yosnaper",
					"yoosnapyoo"
				);
				
				$rnd_ind = mt_rand(0, count($defaultName_arr) - 1);
				
				// add new user			
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `username`, `device_token`, `fb_id`, `gender`, `bio`, `website`, `paid`, `points`, `notifications`, `last_login`, `added`) ';
				$query .= 'VALUES (NULL, "", "'. $device_token .'", "", "N", "", "", "N", "0", "Y", CURRENT_TIMESTAMP, NOW());';
				$result = mysql_query($query);
				$user_id = mysql_insert_id();
				
				$username = $defaultName_arr[$rnd_ind] . $user_id;
				
				// create a default username 
				$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);				
			}
			
			// return
			$user_arr = $this->userObject($user_id);
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Updates a user's name and avatar image
		 * @param $user_id The user's id (integer)
		 * @param $username The new username (string)
		 * @param $img_url The url to the avatar (string)
		 * @return An associative object representing a user (array)
		**/
		function updateUsernameAvatar($user_id, $username, $img_url) {
			
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `img_url` = "'. $img_url .'", `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// return
			$user_arr = $this->userObject($user_id);
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Updates a user's Facebook credentials
		 * @param $user_id The ID for the user (integer)
		 * @param $username The facebook username (string)
		 * @param $fb_id The user's facebook ID (string)
		 * @param $gender The gender according to facebook (string) 
		 * @return An associative object representing a user (array)
		**/
		function updateFB($user_id, $username, $fb_id, $gender) {
			
			// get user info
			$query = 'SELECT `last_login`, `added` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			// declare mail result
			$mail_result = -1;
			
			// first time logged in, send email
			if (strtotime($user_obj->last_login) == strtotime($user_obj->added)) {
				$mail_result = $this->fbEmail($username, "Lorem ipsum sit dolar amat!!");
				$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` ='. $user_id .';';
				
			} else
				$query = 'UPDATE `tblUsers` SET `fb_id` = "'. $fb_id .'", `gender` = "'. $gender .'" WHERE `id` = '. $user_id .';';
			
			$result = mysql_query($query);
			
			
			// check to see if is an invited user
			$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
			$invite_result = mysql_query($query);
			if (mysql_num_rows($invite_result) > 0) {
				$invite_id = mysql_fetch_object($invite_result)->id;
				
				// get any pending challenges for this invited user
				$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 7 AND `challenger_id` = '. $invite_id .';';
				$invite_result = mysql_query($query);
			
				// loop thru the challenges
				while ($challenge_row = mysql_fetch_array($invite_result, MYSQL_BOTH)) {
					
					// update challenge w/ new user id and status
					$query = 'UPDATE `tblChallenges` SET `status_id` = 2, `challenger_id` = "'. $user_id .'" WHERE `id` = '. $challenge_row['id'] .';';
					$result = mysql_query($query);
				}
			}
			
			// return
			$user_arr = $this->userObject($user_id, $mail_result);
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Updates a user's name
		 * @param $user_id The ID for the user (integer)
		 * @param $username The desired username (string)
		 * @return An associative object representing a user (array)
		**/
		function updateName($user_id, $username) {
			
			// check for an already taken name			
			$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'" AND `id` != '. $user_id .';';
			$user_result = mysql_query($query);
			
			// not found
			if (mysql_num_rows($user_result) == 0) {
				
				// update the user's name
				$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'" WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);
				
				// get user info				
				$user_arr = $this->userObject($user_id);
			
			// couldn't update	
			} else
				$user_arr = array('result' => "fail");
			
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Updates a user's account to (non)premium
		 * @param $user_id The ID for the user (integer)
		 * @param $isPaid Y/N whether or not it's a premium account (string) 
		 * @return An associative object representing a user (array)
		**/
		function updatePaid($user_id, $isPaid) {
			
			// update user
			$query = 'UPDATE `tblUsers` SET `paid` = "'. $isPaid .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
					   
			// return
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Gets a user
		 * @param $user_id The ID for the user (integer)
		 * @return An associative object representing a user (array)
		**/
		function getUser($user_id) {
			
			// get user & return
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Gets a user by username
		 * @param $username The name for the user (string)
		 * @return An associative object representing a user (array)
		**/
		function getUserFromName($username) {
			
			$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $username .'";';
			$user_id = mysql_fetch_object(mysql_query($query))->id;
			
			// get user & return
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Updates a user's push notification prefs
		 * @param $user_id The ID for the user (integer)
		 * @param $isNotifications Y/N whether or not to allow pushes (string) 
		 * @return An associative object representing a user (array)
		**/
		function updateNotifications($user_id, $isNotifications) {
			$user_arr = array();
			
			// update user
			$query = 'UPDATE `tblUsers` SET `notifications` = "'. $isNotifications .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			// return
			$user_arr = $this->userObject($user_id);			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
			*/
		}
		
		/**
		 * Pokes a user
		 * @param $poker_id The ID for the user doing the poking (integer)
		 * @param $pokee_id The ID for the user getting poked (integer)
		 * @return An associative object representing a user (array)
		**/
		function pokeUser($poker_id, $pokee_id) {
			
			// add a record to the poke table
			$query = 'INSERT INTO `tblUserPokes` (';
			$query .= '`id`, `user_id`, `poker_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $pokee_id .'", "'. $poker_id .'", NOW());';
			$result = mysql_query($query);
			$poke_id = mysql_insert_id();
			
			// get the user who poked
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $poker_id .';';
			$poker_name = mysql_fetch_object(mysql_query($query))->username;
			
			// get the user who got poked
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $pokee_id .';';
			$pokee_obj = mysql_fetch_object(mysql_query($query));			
			
			// send push if allowed
			if ($pokee_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $pokee_obj->device_token .'"], "type":"2", "aps": {"alert": "'. $poker_name .' has poked you!", "sound": "push_01.caf"}}');
			
			// return
			$this->sendResponse(200, json_encode(array(
				'id' => $poke_id
			)));
			return (true);
			
			/*
			example response:
			{"id":"2","name":"toofus.magnus","token":"d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed","fb_id":"1554917948","gender":"M","paid":"N","points":"50","votes":14,"pokes":22,"notifications":"Y","meta":""}
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
	
	$users = new Users;
	////$users->test();
	
	// action was specified
	if (isset($_POST['action'])) {
		
		// depending on action, call function
		switch ($_POST['action']) {	
			case "0":
				$users->test();
				break;
			
			// add a new user
			case "1":
				if (isset($_POST['token']))
					$users->submitNewUser($_POST['token']);
				break;
			
			// update user's facebook creds
			case "2":
				if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']) && isset($_POST['gender']))
					$users->updateFB($_POST['userID'], $_POST['username'], $_POST['fbID'], $_POST['gender']);
				break;
			
			// update user's account type
			case "3":
				if (isset($_POST['userID']) && isset($_POST['isPaid']))
					$users->updatePaid($_POST['userID'], $_POST['isPaid']);
				break;
			
			// update a user's push notification prefs
			case "4":
				if (isset($_POST['userID']) && isset($_POST['isNotifications']))
					$users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
				break;
			
			// get a user's info
			case "5":
				if (isset($_POST['userID']))
					$users->getUser($_POST['userID']);
				break;
			
			// poke a user
			case "6":
				if (isset($_POST['pokerID']) && isset($_POST['pokeeID']))
					$users->pokeUser($_POST['pokerID'], $_POST['pokeeID']);
				break;
			
			// change a user's name
			case "7":
				if (isset($_POST['userID']) && isset($_POST['username']))
					$users->updateName($_POST['userID'], $_POST['username']);
				break;
				
			// get a user's info
			case "8":
				if (isset($_POST['username']))
					$users->getUserFromName($_POST['username']);
				break;
				
			// updates a user's name and avatar image
			case "9":
				if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['imgURL']))
					$users->updateUsernameAvatar($_POST['userID'], $_POST['username'], $_POST['imgURL']);
				break;
    	}
	}
?>