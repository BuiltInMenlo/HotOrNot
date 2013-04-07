<?php

	class Comments {
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
		 * Gets comments for a particular challenge
		 * @param $challenge_id The user submitting the challenge (integer)
		 * @return An associative object for a challenge (array)
		**/
		function getCommentsForChallenge($challenge_id) {
			$comment_arr = array();
			
			$query = 'SELECT * FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .' AND `status_id` = 1 ORDER BY `added` ASC;';
			$comment_result = mysql_query($query);
			
			// loop thru the rows
			while ($comment_row = mysql_fetch_assoc($comment_result)) {
				
				// user object
				$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $comment_row['user_id'] .';';
			   	$user_obj = mysql_fetch_object(mysql_query($query));
				
				// votes for user
				$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $comment_row['user_id'] .';';
			   	$score = mysql_num_rows(mysql_query($query));
			
				
				// find the avatar image
				if ($user_obj->img_url == "") {
					if ($user_obj->fb_id == "")
						$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
						
					else
						$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
				
				} else
					$avatar_url = $user_obj->img_url;
				
				array_push($comment_arr, array(
					'id' => $comment_row['id'], 
					'challenge_id' => $comment_row['challenge_id'], 
					'user_id' => $comment_row['user_id'], 
					'fb_id' => $user_obj->fb_id,
					'username' => $user_obj->username,
					'img_url' => $avatar_url,
					'score' => $score, 
					'text' => $comment_row['text'], 
					'added' => $comment_row['added']
				));
			}
			
			/// return
			$this->sendResponse(200, json_encode($comment_arr));
			return (true);
		}
		
		/**
		 * Submits a comment for a particular challenge
		 * @param $challenge_id The user submitting the challenge (integer)
		 * @return An associative object for a challenge (array)
		**/
		function submitCommentForChallenge($challenge_id, $user_id, $text) {
			$comment_arr = array();
			
			// add vote record
			$query = 'INSERT INTO `tblComments` (';
			$query .= '`id`, `challenge_id`, `user_id`, `text`, `status_id`, `added`) VALUES (';
			$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $text .'", 1, NOW());';				
			$result = mysql_query($query);
			$comment_id = mysql_insert_id();
			
			// submitting user object
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			// get the challenge object
			$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
			$challenge_obj = mysql_fetch_object(mysql_query($query));
			
			// get subject title for this challenge
			$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
			$subject = mysql_fetch_object(mysql_query($query))->title;
			
			// get the challenge creator
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));
			
			// send push if creator allows it
			if ($creator_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $creator_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $user_obj->username .' has commented on your '. $subject .' challenge!", "sound": "push_01.caf"}}');
			
			// get the challenge challenger
			$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
			$challenger_obj = mysql_fetch_object(mysql_query($query));
			
			// send push if challenger allows it
			if ($challenger_obj->notifications == "Y")
				$this->sendPush('{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"1", "aps": {"alert": "'. $user_obj->username .' has commented on your '. $subject .' challenge!", "sound": "push_01.caf"}}');
			
			
			// get the submitted comment
			$query = 'SELECT * FROM `tblComments` WHERE `id` = '. $comment_id .';';
			$comment_obj = mysql_fetch_object(mysql_query($query));
			
			// votes for user
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $comment_obj->user_id .';';
			$score = mysql_num_rows(mysql_query($query));
			
			// find the avatar image
			if ($user_obj->img_url == "") {
				if ($user_obj->fb_id == "")
					$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
					
				else
					$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
			
			} else
				$avatar_url = $user_obj->img_url;
			
			$comment_arr = array(
				'id' => $comment_obj->id, 
				'challenge_id' => $comment_obj->challenge_id, 
				'user_id' => $comment_obj->user_id, 
				'fb_id' => $user_obj->fb_id,
				'username' => $user_obj->username,
				'img_url' => $avatar_url,
				'score' => $score, 
				'text' => $comment_obj->text, 
				'added' => $comment_obj->added
			);
			
			/// return
			$this->sendResponse(200, json_encode($comment_arr));
			return (true);
		}
		
		/**
		 * Flags a comment
		 * @param $comment_id The comment's ID (integer)
		 * @return The ID of the comment (integer)
		**/
		function flagComment($comment_id) {
						
			// update the comment status
			$query = 'UPDATE `tblComments` SET `status_id` = 2 WHERE `id` = '. $comment_id .';';
			$result = mysql_query($query);			
			
			// return
			$this->sendResponse(200, json_encode(array(
				'id' => $comment_id
			)));
			return (true);
		}
		
		/**
		 * Removes a comment
		 * @param $comment_id The comment's ID (integer)
		 * @return The ID of the comment (integer)
		**/
		function deleteComment($comment_id) {
						
			// update the comment status
			$query = 'UPDATE `tblComments` SET `status_id` = 3 WHERE `id` = '. $comment_id .';';
			$result = mysql_query($query);			
			
			// return
			$this->sendResponse(200, json_encode(array(
				'id' => $comment_id
			)));
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
	
	$comments = new Comments;
	////$comments->test();
	
	// action was specified
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			case "0":
				$comments->test();
				break;
			
			// get list of comments for challenge
			case "1":
				if (isset($_POST['challengeID']))
					$comments->getCommentsForChallenge($_POST['challengeID']);
				break;
			
			// add a comment for a challenge
			case "2":
				if (isset($_POST['challengeID']) && isset($_POST['userID']) && isset($_POST['text']))
					$comments->submitCommentForChallenge($_POST['challengeID'], $_POST['userID'], $_POST['text']);
				break;
				
			// add a comment for a subject
			case "3":
				if (isset($_POST['subjectID']) && isset($_POST['userID']) && isset($_POST['text']))
					$comments->submitCommentForSubject($_POST['subjectID'], $_POST['userID'], $_POST['text']);
				break;
				
			// get a specific comment				
			case "4":
				if (isset($_POST['commentID']))
					$comments->getComment($_POST['commentID']);
				break;
				
			// get a list of comments for a user
			case "5":
				if (isset($_POST['userID']))
					$comments->getCommentsForUser($_POST['userID']);
				break;
				
			// get a list of comments for a subject
			case "6":
				if (isset($_POST['subjectID']))
					$comments->getCommentsForSubject($_POST['subjectID']);
				break;
				
			// flags a comment
			case "7":
				if (isset($_POST['commentID']))
					$comments->flagComment($_POST['commentID']);
				break;
				
			// removes a comment
			case "8":
				if (isset($_POST['commentID']))
					$comments->deleteComment($_POST['commentID']);
				break;
    	}
	}
?>