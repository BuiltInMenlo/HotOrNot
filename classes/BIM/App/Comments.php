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
        $comment = $volley->comment( $userId, $text );
        BIM_Push::commentPush($userId, $volleyId);
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

