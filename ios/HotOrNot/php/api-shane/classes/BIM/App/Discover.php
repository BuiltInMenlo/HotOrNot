<?php

require_once 'BIM/App/Base.php';

class BIM_App_Discover extends BIM_App_Base{
	
	/**
	 * Helper function that returns a challenge based on ID
	 * @param $challenge_id The ID of the challenge to get (integer)
	 * @return An associative object for a challenge (array)
	**/
	public function getChallengeObj ($challenge_id) {
		$this->dbConnect();
	    $challenge_arr = array();
		
		// get challenge row
		$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
					
		// get subject title for this challenge
		$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
		$subject_obj = mysql_fetch_object(mysql_query($query));
		
		// get total number of comments
		$query = 'SELECT `id` FROM `tblComments` WHERE `challenge_id` = '. $challenge_id .';';
		$comments = mysql_num_rows(mysql_query($query));
		
		// get rechallenges
		$rechallenge_arr = array();
		$query = 'SELECT `id`, `creator_id`, `added` FROM `tblChallenges` WHERE `subject_id` = '. $challenge_obj->subject_id .' AND `added` > "'. $challenge_obj->added .'" ORDER BY `added` ASC LIMIT 10;';
		$rechallenge_result = mysql_query($query);
		
		// loop thru the rows
		while ($rechallenge_row = mysql_fetch_assoc($rechallenge_result)) {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $rechallenge_row['creator_id'] .';';
			$user_obj = mysql_fetch_object(mysql_query($query));
			
			// find the avatar image
			if ($user_obj->img_url == "") {
				if ($user_obj->fb_id == "")
					$avatar_url = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
				
				else
					$avatar_url = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
		
			} else
				$avatar_url = $user_obj->img_url;
			
			array_push($rechallenge_arr, array(
				'id' => $rechallenge_row['id'],
				'user_id' => $rechallenge_row['creator_id'],
				'fb_id' => $user_obj->fb_id,
				'img_url' => $avatar_url,
				'username' => $user_obj->username,
				'added' => $rechallenge_row['added']
			));
		}
		
		
		// compose object
		$challenge_arr = array(
			'id' => $challenge_obj->id, 
			'status' => $challenge_obj->status_id, 
			'subject' => $subject_obj->title, 
			'comments' => $comments, 
			'has_viewed' => $challenge_obj->hasPreviewed, 
			'started' => $challenge_obj->started, 
			'added' => $challenge_obj->added, 
			'creator' => $this->userForChallenge($challenge_obj->creator_id, $challenge_obj->id),
			'challenger' => $this->userForChallenge($challenge_obj->challenger_id, $challenge_obj->id),
			'rechallenges' => $rechallenge_arr
		); 
		
		// return
		return ($challenge_arr);
	}
	
	/**
	 * Helper function to user info for a challenge
	 * @param $user_id The creator or challenger ID (integer)
	 * @param $challenge_id The challenge's ID to get the user for (integer)
	 * @return An associative object for a user (array)
	**/
	public function userForChallenge($user_id, $challenge_id) {
		$this->dbConnect();
	    
		// prime the user
		$user_arr = array(
			'id' => $user_id, 
			'fb_id' => "",
			'username' => "",
			'avatar' => "", 
			'img' => "",
			'score' => 0				
		);
		
		// challenge object
		$query = 'SELECT `status_id`, `creator_id`, `challenger_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
		$challenge_obj = mysql_fetch_object(mysql_query($query));
		
		// user is the creator
		if ($user_id == $challenge_obj->creator_id) {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_arr['img'] = $challenge_obj->creator_img;
						
		// user is the challenger
		} else {
			$query = 'SELECT `fb_id`, `username`, `img_url` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$user_arr['img'] = $challenge_obj->challenger_img;			
			
			// invited challenger
			if ($challenge_obj->status_id == "7")
				$query = 'SELECT `fb_id`, `username` FROM `tblInvitedUsers` WHERE `id` = '. $user_id .';';
		}
		
		// user object
		$user_obj = mysql_fetch_object(mysql_query($query));
		
		// votes for challenger
		$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
	   	$score_result = mysql_query($query);
					
		while ($score_row = mysql_fetch_assoc($score_result)) {										
			if ($score_row['challenger_id'] == $user_id)
				$user_arr['score']++;
		}
		
		// user info
		if ($user_obj != null) {
			$user_arr['fb_id'] = $user_obj->fb_id;
			$user_arr['username'] = $user_obj->username;
			
			// find the avatar image
			if ($user_obj->img_url == "") {
				if ($user_obj->fb_id == "")
					$user_arr['avatar'] = "https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png";
				
				else
					$user_arr['avatar'] = "https://graph.facebook.com/". $user_obj->fb_id ."/picture?type=square";
		
			} else
				$user_arr['avatar'] = $user_obj->img_url;
		}
		
		return ($user_arr);
	}
	
	
	/**
	 * Gets the challenges by total votes
	 * @return An associative array containing user info (array)
	**/
	public function getTopChallengesByVotes() {
		$this->dbConnect();
	    $challenge_arr = array();
		
		$now_date = date('Y-m-d H:i:s', time());
		$start_date = date('Y-m-d H:i:s', strtotime($now_date .' - 90 days'));
		
		// $this->sendResponse(200, json_encode(array('now_date' => $now_date, 'start_date' => $start_date, 'query' => 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 AND `started` > "'. $start_date .'" ORDER BY `votes` DESC LIMIT;')));
		// return (true);
		
		// get the challenge rows
		$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 AND `started` > "'. $start_date .'" ORDER BY `votes` DESC LIMIT 256;';
		$result = mysql_query($query);
		
		// loop thru challenge rows
		while ($row = mysql_fetch_assoc($result)) {
					
			// push challenge into array
			array_push($challenge_arr, $this->getChallengeObj($row['id']));
		}
		
		if (count($challenge_arr) % 2 == 1)
			array_pop($challenge_arr);
		
		// return
		return $challenge_arr;
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

