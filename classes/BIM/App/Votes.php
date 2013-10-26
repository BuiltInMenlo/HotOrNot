<?php

/*
Votes
action 1 - ( getChallengesByActivity ),
action 2 - ( getChallengesForSubjectID ),
action 3 - ( getChallengeForChallengeID ),
action 4 - ( getChallengesByDate ),
action 5 - ( getVotersForChallenge ),
action 6 - ( upvoteChallenge ),
action 7 - ( getChallengesWithChallenger ),
action 8 - ( getChallengesForSubjectName ),
action 9 - ( getChallengesForUsername ),
action 10 - ( getChallengesWithFriends ),
 * 
 */

class BIM_App_Votes extends BIM_App_Base{
    
	/** 
	 * Gets the list of challenges sorted by total votes
	 * @param $user_id The ID of the user (integer)
	 * @return The list of challenges (array)
	**/
	public function getChallengesByActivity() {
        $volleys = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getChallengesByActivity();
        $volleys = BIM_Model_Volley::getMulti($ids);
        return $volleys;
	}
	
	/** 
	 * Gets the list of challenges sorted by date
	 * @return The list of challenges (array)
	**/
	public function getChallengesByCreationTime() {
        $volleys = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getChallengesByCreationTime();
        $volleys = BIM_Model_Volley::getMulti($ids);
        return $volleys;
	}
	
	/** 
	 * Gets the list of challenges sorted by date
	 * @return The list of challenges (array)
	**/
	public function getChallengesByDate() {
        $volleys = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getChallengesByDate();
        $volleys = BIM_Model_Volley::getMulti($ids);
        return $volleys;
	}
	
	/** 
	 * Gets the list of challenges for a subject
	 * @param $subject_id The ID of the subject (integer)
	 * @return The list of challenges (array)
	**/	
	public function getChallengesForSubjectID($subjectId, $private = false ) {
        $volleys = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getVolleysForHashTagId( $subjectId, $private );
        $volleys = BIM_Model_Volley::getMulti($ids);
        return $volleys;
	}
	
	public function getChallengesForSubjectName($subjectName, $private = false ) {
        $volleys = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getVolleysForHashTag( $subjectName, $private );
        $volleys = BIM_Model_Volley::getMulti($ids);
        return $volleys;
	}
	
	/** 
	 * Gets the latest list of 50 challenges for a user
	 * @param $username The username of the user (string)
	 * @return The list of challenges (array)
	**/	
	public function getChallengesForUsername($username, $private = false ) {
	    $volleys = array();
	    $user = BIM_Model_User::getByUsername($username);
		if ( $user && $user->isExtant() ) {
            $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
            $ids = $dao->getVolleysForUserId( $user->id, $private );
            $volleys = BIM_Model_Volley::getMulti($ids);
		}
		return $volleys;
	}
	
	/** 
	 * Gets the latest list of 50 challenges for a user
	 * @param $username The username of the user (string)
	 * @return The list of challenges (array)
	**/	
	public function getChallengesForProfile($username, $private = false ) {
	    $volleys = array();
	    $user = BIM_Model_User::getByUsername($username);
		if ( $user && $user->isExtant() ) {
            $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
            $ids = $dao->getVolleysForProfile( $user->id, $private );
            $volleys = BIM_Model_Volley::getMulti($ids);
		}
		return $volleys;
	}
	
	public function getChallengesWithFriends($input) {
        return BIM_Model_Volley::getVolleysWithFriends( $input->userID );
	}
	
	/** 
	 * Gets a list of challenges between two users
	 * @param $user_id The ID of the first user (integer)
	 * @param $challenger_id The ID of the second user (integer)
	 * @return The list of challenges (array)
	**/
	public function getChallengesWithChallenger($userId, $friendId, $private = false ) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getVolleysWithAFriend($userId, $friendId, $private);
        return BIM_Model_Volley::getMulti( $ids );
	}
	
	/** 
	 * Gets a challenge for an ID
	 * @param $subject_id The ID of the subject (integer)
	 * @return An associative object of a challenge (array)
	**/
	public function getChallengeForChallengeID($volleyId) {
		return array( BIM_Model_Volley::get( $volleyId ) );
	}
	
	
	/** 
	 * Gets the voters for a particular challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @return An associative object of the users (array)
	**/
	public function getVotersForChallenge( $volleyId )  {
        $users = array();
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $counts = $dao->getVoterCounts( $volleyId );
        
        $ids = array();
        $votes = array();
        foreach( $counts as $countData ){
            $ids[] = $countData->id;
            $votes[ $countData->id ] = $countData->count;
        }
        
        $volley = BIM_Model_Volley::get($volleyId);
        $users = BIM_Model_User::getMulti($ids);
        
		// loop thru votes
		foreach( $users as &$user ){
			$user->img_url = $user->getAvatarUrl();
			$user->votes = $votes[ $user->id ];
			$user->challenges = $user->pics;
			$user->challengers = $volley->challengers;
			$user->added = $volley->added;
		}
		
		// return
		return $users;
	}
	
	/** 
	 * Upvotes a challenge
	 * @param $challenge_id The ID of the challenge (integer)
	 * @param $user_id The ID of the user performing the upvote
	 * @param $targetId the id of the user receiving the vote
	 * @return An associative object of the challenge (array)
	**/
	public function upvoteChallenge($volleyId, $userId, $targetId, $imgUrl ) {
	    $volley = BIM_Model_Volley::get($volleyId);
	    if( $volley->isExtant() && $volley->hasUser( $targetId ) ){
	        $volley->upVote( $targetId, $userId, $imgUrl );
	        if( $userId != $targetId ){
	            BIM_Push::likePush($userId, $targetId, $volleyId);
	        }
	    }
		return BIM_Model_Volley::get( $volleyId );
	}
}
