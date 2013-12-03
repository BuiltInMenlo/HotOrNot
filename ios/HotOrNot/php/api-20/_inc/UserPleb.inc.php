<?php

class UserPleb {
	
	//private $db_conn;
	
	public function __construct() {
		//$this->db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
		//mysql_select_db('hotornot-dev') or die("Could not select database.");	
	}
	
	public function __destruct() {
		/*if ($this->db_conn) {
			mysql_close($this->db_conn);
			$this->db_conn = null;
		}*/
	}
	
	/**
	 * Helper function to retrieve a user's info
	 * @param $user_id The ID of the user to get (integer)
	 * @param $meta Any extra info to include (string)
	 * @return An associative object for a user (array)
	**/ 
	public static function userObject($user_id, $meta="") {
		
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
		
		
		// return
		return(array(
			'id' => $row->id, 
			'username' => $row->username,
			'name' => $row->username, 
			'token' => $row->device_token, 
			'fb_id' => $row->fb_id, 
			'gender' => $row->gender, 
			'avatar_url' => UserPleb::avatarURLForUser($row),
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
	 * Helper function to get the correct user avatar
	 * @param $user_arr A associative array of the user (array)
	 * @return A url to an image (string)
	**/
	public static function avatarURLForUser($user_arr) {
		
		// no custom url
		if ($user_arr['img_url'] == "") {
			
			// has fb login
			if ($user_arr['fb_id'] != "")
				return ("https://graph.facebook.com/". $user_arr['fb_id'] ."/picture?type=square");
			
			// has nothing, default
			else
				return ("https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png");
		}
		
		// use custom
		return ($user_arr['img_url']);
	}
}
?>