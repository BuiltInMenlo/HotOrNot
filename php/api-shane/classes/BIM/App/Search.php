<?php

require_once 'BIM/App/Base.php';

class BIM_App_Search extends BIM_App_Base{
	
	/**
	 * Helper function to get user info for a search result
	 * @param $user_id The user's ID (integer)
	 * @return An associative object for a user (array)
	**/
	public function userForSearchResult($user_id) {
		$this->dbConnect();
	    
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
	public function getUsersLikeUsername($username) {
		$this->dbConnect();
	    $user_arr = array();
		
		// get the user rows
		$query = 'SELECT `id` FROM `tblUsers` WHERE `username` LIKE "%'. $username .'%";';
		$user_result = mysql_query($query);
		
		// loop thru user rows
		while ($user_row = mysql_fetch_assoc($user_result))
			array_push($user_arr, $this->userForSearchResult($user_row['id']));
			
		
		// return
		return $user_arr;
	}
	
	/**
	 * Gets the top 250 subjects by challenges created
	 * @return An associative array containing user info (array)
	**/
	public function getSubjectsLikeSubject($subject_name) {
		$this->dbConnect();
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
		return $subject_arr;
	}
	
	/** 
	 * Gets the list of users
	 * @param $usernames The names of the users (string)
	 * @return The list of users (array)
	**/
	public function getDefaultUsers($usernames) {
		$this->dbConnect();
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
		return $user_arr;
	}
	
	/**
	 * Gets the list of users someone has snapped with
	 * @param $user_id The id of the user (integer)
	 * @return The list of users (array)
	**/
	public function getSnappedUsers($user_id) {
		$this->dbConnect();
	    
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
		return $user_arr;
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
