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
				
		function sendResponse($status=200, $body='', $content_type='text/html') {			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			
			header($status_header);
			header("Content-type: ". $content_type);
			
			echo ($body);
		}
	    
		
		function getPopularByUsers($user_id) {
			$user_arr = array();
			
			$query = 'SELECT * FROM `tblUsers` ORDER BY `points` DESC LIMIT 250;';
			$user_result = mysql_query($query);
			
			while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) {				
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_row['id'] .';';
				$votes = mysql_num_rows(mysql_query($query));
				
				$query = 'SELECT `id` FROM `tblUserPokes` WHERE `user_id` = '. $user_row['id'] .';';
				$pokes = mysql_num_rows(mysql_query($query));
			
				array_push($user_arr, array(
					'id' => $user_row['id'], 
					'username' => $user_row['username'], 					
					'img_url' => "https://graph.facebook.com/". $user_row['fb_id'] ."/picture?type=square",   
					'points' => $user_row['points'],
					'votes' => $votes,
					'pokes' => $pokes
				));	
			}
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
		}
		
		//https://itunes.apple.com/us/album/call-me-maybe/id557372575?i=557373187&uo=4&v0=WWW-NAUS-ITSTOP100-SONGS
		function getPopularBySubject($user_id) {
			$subject_arr = array();
			
			$query = 'SELECT * FROM `tblChallengeSubjects` LIMIT 250;';
			$subject_result = mysql_query($query);
			
			while ($subject_row = mysql_fetch_array($subject_result, MYSQL_BOTH)) {
				$query = 'SELECT `id`, `status_id` FROM `tblChallenges` WHERE `subject_id` = '. $subject_row['id'] .';';
				$result = mysql_query($query);
				$row = mysql_fetch_object($result);
				
				$preview_url = "";
				if ($subject_row['itunes_id'] != "") {
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, "http://itunes.apple.com/lookup?country=us&id=". $subject_row['itunes_id']);
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
				
				$active = 0;
				if ($row->status_id == 4)
					$active++;
					
				array_push($subject_arr, array(
					'id' => $subject_row['id'], 
					'name' => $subject_row['title'], 					
					'img_url' => "", 
					'preview_url' => $preview_url,   
					'score' => mysql_num_rows($result), 
					'active' => $active
				));	
			}
				
			
			$this->sendResponse(200, json_encode($subject_arr));
			return (true);	
		}
		
		
		function test() {
			$this->sendResponse(200, json_encode(array(
				'result' => true
			)));
			return (true);	
		}
	}
	
	$popular = new Popular;
	////$popular->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['userID']))
					$popular->getPopularByUsers($_POST['userID']);
				break;
				
			case "2":
				if (isset($_POST['userID']))
					$popular->getPopularBySubject($_POST['userID']);
				break;			
    	}
	}
?>