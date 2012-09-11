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
			
			
			$range_result = mysql_query(" SELECT MAX(`id`) AS max_id , MIN(`id`) AS min_id FROM `tblUsers`");
			$range_row = mysql_fetch_object($range_result); 
			$rndUser_id = mt_rand($range_row->min_id , $range_row->max_id);			
			
			$query = 'INSERT INTO `tblChallenges` (';
			$query .= '`id`, `status_id`, `subject_id`, `creator_id`, `img_url`, `started`, `added`) ';
			$query .= 'VALUES (NULL, "2", "'. $subject_id .'", "'. $user_id .'", "", "0000-00-00 00:00:00", NOW());';
			$result = mysql_query($query);
			$challenge_id = mysql_insert_id();
			
			
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
				
						
    	}
	}
?>