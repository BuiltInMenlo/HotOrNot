<?php

	class Search {
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
		 * Helper function to get user info for a search result
		 * @param $user_id The user's ID (integer)
		 * @return An associative object for a user (array)
		**/
		function userForSearchResult($user_id) {
			
			// get the user row
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_row = mysql_fetch_assoc(mysql_query($query));
			
			// get total for this user
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_row['id'] .';';
			$votes = mysql_num_rows(mysql_query($query));
			
			// get total pokes for this
			$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_row['id'] .';';
			$pokes = mysql_num_rows(mysql_query($query));
			
			// find the avatar image
			if ($user_row['img_url'] == "") {
				if ($user_row['fb_id'] == "")
					$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
					
				else
					$avatar_url = "https://graph.facebook.com/". $user_row['fb_id'] ."/picture?type=square";
			
			} else
				$avatar_url = $user_row['img_url'];
			
			// return array
			return(array(
				'id' => $user_row['id'], 
				'username' => $user_row['username'], 
				'fb_id' => $user_row['fb_id'], 					
				'avatar_url' => $avatar_url,   
				'points' => $user_row['points'],
				'votes' => $votes,
				'pokes' => $pokes
			));
		}
		
		
		
		/** 
		 * Gets the list of challenges sorted by total votes
		 * @param $user_id The ID of the user (integer)
		 * @return The list of challenges (array)
		**/
		function getUsersLikeUsername($username) {
			$user_arr = array();
			
			// get the user rows
			$query = 'SELECT `id` FROM `tblUsers` WHERE `username` LIKE "%'. $username .'%";';
			$user_result = mysql_query($query);
			
			// loop thru user rows
			while ($user_row = mysql_fetch_assoc($user_result))
				array_push($user_arr, $this->userForSearchResult($user_row['id']));
				
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		/**
		 * Gets the top 250 subjects by challenges created
		 * @return An associative array containing user info (array)
		**/
		function getSubjectsLikeSubject($subject_name) {
			$subject_arr = array();
			
			// get the subject rows
			$query = 'SELECT * FROM `tblChallengeSubjects` WHERE `title` LIKE "%'. $subject_name .'%";';
			$subject_result = mysql_query($query);
			
			// loop thru subject rows
			while ($subject_row = mysql_fetch_assoc($subject_result)) {
				$query = 'SELECT `id`, `status_id` FROM `tblChallenges` WHERE `subject_id` = '. $subject_row['id'] .';';
				$result = mysql_query($query);
				$row = mysql_fetch_object($result);
				
				// calculate the active challenges
				$active = 0;
				if ($row && $row->status_id == "4")
					$active++;
				
				// push into array
				array_push($subject_arr, array(
					'id' => $subject_row['id'], 
					'name' => $subject_row['title'], 					
					'avatar_url' => "", 
					'score' => mysql_num_rows($result), 
					'active' => $active
				));	
			}
				
			// return
			$this->sendResponse(200, json_encode($subject_arr));
			return (true);
		}
		
		/** 
		 * Gets the list of users
		 * @param $usernames The names of the users (string)
		 * @return The list of users (array)
		**/
		function getDefaultUsers($usernames) {
			$user_arr = array();
			$username_arr = explode('|', $usernames);
			
			// loop thru usernames
			foreach ($username_arr as $key => $val) {			
				// get the user row
				$query = 'SELECT `id` FROM `tblUsers` WHERE `username` = "'. $val .'";';
				$user_id = mysql_fetch_object(mysql_query($query))->id;				
				array_push($user_arr, $this->userForSearchResult($user_id));
			}
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		/**
		 * Gets the list of users someone has snapped with
		 * @param $user_id The id of the user (integer)
		 * @return The list of users (array)
		**/
		function getSnappedUsers($user_id) {
			
			// return object
			$user_arr = array();
			
			// list of user ids
			$userID_arr = array();
			
			
			// get the previous challengers
			$query = 'SELECT `challenger_id` FROM `tblChallenges` WHERE `challenger_id` != 0 AND `creator_id` = '. $user_id .' ORDER BY `updated` DESC LIMIT 8;';
			$result = mysql_query($query);
			
			// loop thru result ids
			while ($row = mysql_fetch_assoc($result)) {
				$isFound = false;
				
				// check for an id already in array
				foreach ($userID_arr as $key => $val) {
					if ($val == $row['challenger_id']) {
						$isFound = true;
						break;
					}
				}
				
				if (!$isFound)
					array_push($userID_arr, $row['challenger_id']);
			}
				
				
			// get the previous challenge creators
			$query = 'SELECT `creator_id` FROM `tblChallenges` WHERE `challenger_id` = '. $user_id .' ORDER BY `updated` DESC LIMIT 8;';
			$result = mysql_query($query);
			
			// loop thru result ids
			while ($row = mysql_fetch_assoc($result)) {
				$isFound = false;
				
				// check for an id already in array
				foreach ($userID_arr as $key => $val) {
					if ($val == $row['creator_id']) {
						$isFound = true;
						break;
					}
				}
				
				if (!$isFound)
					array_push($userID_arr, $row['creator_id']);
			}
			
			
			// get the user for each id
			foreach ($userID_arr as $key => $val)
				array_push($user_arr, $this->userForSearchResult($val));
			
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
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
	
	$search = new Search;
	////$search->test();
	
	// action was specified
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			case "0":
				$search->test();
				break;
			
			// get list of usernames containing a string
			case "1":				
				if (isset($_POST['username']))
					$search->getUsersLikeUsername($_POST['username']);
				break;
			
			// get list of subjects containing a string
			case "2":
				if (isset($_POST['subjectName']))
					$search->getSubjectsLikeSubject($_POST['subjectName']);
				break;
			
			// get list of users from defaults
			case "3":
				if (isset($_POST['usernames']))
					$search->getDefaultUsers($_POST['usernames']);
				break;
				
			// get users someone has snapped with
			case "4":
				if (isset($_POST['userID']))
					$search->getSnappedUsers($_POST['userID']);
				break;
			
    	}
	}
?>