<?php

	class Popular {
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
		 * Gets the top 250 users by challenges created
		 * @return An associative array containing user info (array)
		**/
		function getPopularByUsers() {
			$user_arr = array();
			
			// get the user rows
			$query = 'SELECT * FROM `tblUsers` ORDER BY `points` DESC LIMIT 100;';
			$user_result = mysql_query($query);
			
			// loop thru user rows
			while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) {				
				
				// get total for this user
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_row['id'] .';';
				$votes = mysql_num_rows(mysql_query($query));
				
				// get total pokes for this
				$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_row['id'] .';';
				$pokes = mysql_num_rows(mysql_query($query));
				
				// push user info into array
				array_push($user_arr, array(
					'id' => $user_row['id'], 
					'username' => $user_row['username'], 
					'fb_id' => $user_row['fb_id'], 					
					'img_url' => "https://graph.facebook.com/". $user_row['fb_id'] ."/picture?type=square",   
					'points' => $user_row['points'],
					'votes' => $votes,
					'pokes' => $pokes
				));	
			}
			
			// return
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
			
			/* 
			example response:
			[{"id":"236","username":"Courtney","img_url":"https:\/\/graph.facebook.com\/100000466174725\/picture?type=square","points":"337","votes":39,"pokes":0}]
			*/
		}
		
		/**
		 * Gets the top 250 subjects by challenges created
		 * @return An associative array containing user info (array)
		**/
		function getPopularBySubject() {
			$subject_arr = array();
			
			// get the subject rows
			$query = 'SELECT * FROM `tblChallengeSubjects` LIMIT 100;';
			$subject_result = mysql_query($query);
			
			// loop thru subject rows
			while ($subject_row = mysql_fetch_array($subject_result, MYSQL_BOTH)) {
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
					'img_url' => "", 
					'score' => mysql_num_rows($result), 
					'active' => $active
				));	
			}
				
			// return
			$this->sendResponse(200, json_encode($subject_arr));
			return (true);
			
			/*
			example response:
			[{"id":"161","name":"#derp","img_url":"","score":2,"active":0},{"id":"162","name":"workItFace","img_url":"","score":1,"active":0}]
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
	
	$popular = new Popular;
	////$popular->test();
	
	
	// action was specified
	if (isset($_POST['action'])) {
		
		// depending on action, call function
		switch ($_POST['action']) {
			case "0":
				$popular->test();
				break;
			
			// get list of top users
			case "1":
				$popular->getPopularByUsers();
				break;
			
			// get list of top subjects
			case "2":
				$popular->getPopularBySubject();
				break;			
    	}
	}
?>