<?php

require_once 'BIM/App/Base.php';

class BIM_App_Search extends BIM_App_Base{
	
	/** 
	 * Gets the list of challenges sorted by total votes
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	public function getUsersLikeUsername($username) {
	    $users = BIM_Model_User::getUsersWithSimilarName( $username );
		return $users;
	}
	
	/**
	 * Gets the top 250 subjects by challenges created
	 * @return An associative array containing user info (array)
	**/
	public function getSubjectsLikeSubject($subjectName) {
	    $tags = BIM_Model_Volley::getTopHashTags($subjectName);
		foreach( $tags as &$tag ) {
    		$tags->avatar_url = ""; 
    		$tags->active = 0;
		}
		return $tags;
	}
	
	/** 
	 * Gets the list of users
	 * @param $usernames The names of the users (string)
	 * @return The list of users (array)
	**/
	public function getDefaultUsers($usernames) {
		$users = explode('|', $usernames);
		foreach ( $users as &$username ) {			
			$username = BIM_Model_User::getByUsername( $username );
		}
		return $users;
	}
	
	/**
	 * Gets the list of users someone has snapped with
	 * @param $user_id The id of the user (integer)
	 * @return The list of users (array)
	**/
	public function getSnappedUsers( $userId ) {
        $user = BIM_Model_User::get($userId);
		$users = $user->getOpponenetsWithSnaps();
		return $users;
	}
}
