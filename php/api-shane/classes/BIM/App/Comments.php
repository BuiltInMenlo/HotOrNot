<?php
/*
Comments
action 2 - ( submitCommentForChallenge ),
*/

require_once 'BIM/App/Base.php';

class BIM_App_Comments extends BIM_App_Base{
	
	/** 
	 * Helper function to send an Urban Airship push
	 * @param $msg The message body of the push (string)
	 * @return null
	**/
    public function sendPush($msg) {
        return;
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
    public function getCommentsForChallenge($challenge_id) {
		$this->dbConnect();
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
		return $comment_arr;
	}
	
	/**
	 * Submits a comment for a particular challenge
	 * @param $challenge_id The user submitting the challenge (integer)
	 * @return An associative object for a challenge (array)
	**/
    public function submitCommentForChallenge($challenge_id, $user_id, $text) {
		$this->dbConnect();
	    $comment_arr = array();
		
		// add vote record
		$query = 'INSERT INTO `tblComments` (';
		$query .= '`id`, `challenge_id`, `user_id`, `text`, `status_id`, `added`) VALUES (';
		$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $text .'", 1, NOW());';				
		$result = mysql_query($query);
		$comment_id = mysql_insert_id();
		
		// update the time
		$query = 'UPDATE `tblChallenges` SET `updated` = NOW() WHERE `id` = '. $challenge_id .';';
		$result = mysql_query($query);
		
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
		$query = 'SELECT `id`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
		$creator_obj = mysql_fetch_object(mysql_query($query));
		
		// send push if creator allows it
		if ($creator_obj->notifications == "Y" && $creator_obj->id != $user_id)
			$this->sendPush('{"device_tokens": ["'. $creator_obj->device_token .'"], "type":"3", "aps": {"alert": "'. $user_obj->username .' has commented on your '. $subject .' snap!", "sound": "push_01.caf"}}');
		
		// get the challenge challenger
		$query = 'SELECT `id`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
		$challenger_obj = mysql_fetch_object(mysql_query($query));
		
		// send push if challenger allows it
		if ($challenger_obj->notifications == "Y" && $challenger_obj->id != $user_id)
			$this->sendPush('{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"3", "aps": {"alert": "'. $user_obj->username .' has commented on your '. $subject .' snap!", "sound": "push_01.caf"}}');
		
		
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
		return $comment_arr;
	}
	
	/**
	 * Flags a comment
	 * @param $comment_id The comment's ID (integer)
	 * @return The ID of the comment (integer)
	**/
    public function flagComment($comment_id) {
		$this->dbConnect();
	    
		// update the comment status
		$query = 'UPDATE `tblComments` SET `status_id` = 2 WHERE `id` = '. $comment_id .';';
		$result = mysql_query($query);			
		
		// return
		return array(
			'id' => $comment_id
		);
	}
	
	/**
	 * Removes a comment
	 * @param $comment_id The comment's ID (integer)
	 * @return The ID of the comment (integer)
	**/
    public function deleteComment($comment_id) {
		$this->dbConnect();
	    
		// update the comment status
		$query = 'UPDATE `tblComments` SET `status_id` = 3 WHERE `id` = '. $comment_id .';';
		$result = mysql_query($query);			
		
		// return
		return array(
			'id' => $comment_id
		);
	}
	
	
	/**
	 * Debugging function
	**/
    public function test() {
		return array(
			'result' => true
		);
	}
}

