<?php
/*
Comments
action 2 - ( submitCommentForChallenge ),
*/

require_once 'BIM/App/Base.php';

class BIM_App_Comments extends BIM_App_Base{
	
	/**
	 * Gets comments for a particular challenge
	 * @param $challenge_id The user submitting the challenge (integer)
	 * @return An associative object for a challenge (array)
	**/
    public function getCommentsForChallenge($volleyId) {
        $volley = BIM_Model_Volley::get($volleyId);
        return $volley->getComments();
	}
	
	/**
	 * Submits a comment for a particular challenge
	 * @param $challenge_id The user submitting the challenge (integer)
	 * @return An associative object for a challenge (array)
	**/
    public function submitCommentForChallenge($volleyId, $userId, $text) {
        
        $volley = BIM_Model_Volley::get($volleyId);
        $commenter = BIM_Model_User::get($userId);
        $creator = BIM_Model_User::get( $volley->creator->id );
        $comment = $volley->comment( $userId, $text );

        $userIds = $volley->getUsers();
	    $users = BIM_Model_User::getMulti( $userIds );
	    
	    $deviceTokens = array();
	    foreach( $users as $user ){
	        $deviceTokens[] = $user->device_token;
	    }
        
		// send push if creator allows it
		if ($creator->notifications == "Y" && $creator->id != $userId){
            $msg = "$commenter->username has commented on your $volley->subject snap!";
			$push = array(
		    	"device_tokens" =>  $deviceTokens, 
		    	"type" => "3", 
		    	"aps" =>  array(
		    		"alert" =>  $msg,
		    		"sound" =>  "push_01.caf"
		        )
		    );
    	    BIM_Push_UrbanAirship_Iphone::sendPush( $push );
		}
		
		return $comment;
	}
	
	/**
	 * Flags a comment
	 * @param $comment_id The comment's ID (integer)
	 * @return The ID of the comment (integer)
	**/
    public function flagComment($commentId) {
        $comment = BIM_Model_Comments::get($commentId);
        $comment->flag();
		return array(
			'id' => $commentId
		);
	}
	
	/**
	 * Removes a comment
	 * @param $comment_id The comment's ID (integer)
	 * @return The ID of the comment (integer)
	**/
    public function deleteComment($commentId) {
        $comment = BIM_Model_Comments::get($commentId);
        $comment->delete();
        return array(
			'id' => $commentId
		);
	}
}

