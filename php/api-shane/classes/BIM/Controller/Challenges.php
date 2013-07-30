<?php

class BIM_Controller_Challenges extends BIM_Controller_Base {
    
    public function test(){
        $challenges = new BIM_App_Challenges();
        return $challenges->test();
    }
    
    public function getChallengesForUserBeforeDate(){
        if (isset($_POST['userID']) && isset($_POST['prevIDs']) && isset($_POST['datetime'])){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUserBeforeDate($_POST['userID'], $_POST['prevIDs'], $_POST['datetime']);
        }
    }    
    
    public function submitChallengeWithChallenger(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL) && isset($input->challengerID)){
            $isPrivate = !empty( $input->isPrivate ) ? $input->isPrivate : 'N';
            $expires = $this->resolveExpires();
            $challenges = new BIM_App_Challenges;
            return $challenges->submitChallengeWithChallenger($input->userID, $input->subject, $input->imgURL, $input->challengerID, $isPrivate, $expires );
        }
    }
    
    public function updatePreviewed(){
        if (isset($_POST['challengeID'])){
            $challenges = new BIM_App_Challenges();
            return $challenges->updatePreviewed($_POST['challengeID']);
        }
    }
    
    public function getPreviewForSubject(){
        if (isset($_POST['subjectName'])){
            $challenges = new BIM_App_Challenges();
            return $challenges->getPreviewForSubject($_POST['subjectName']);
        }
    }
    
    public function getAllChallengesForUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( isset( $input->userID ) ){
            $challenges = new BIM_App_Challenges();
            return $challenges->getAllChallengesForUser( $input->userID );
        }
    }

    public function getChallengesForUser(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if ( !empty( $input->userID ) ){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUser( $input->userID );
        }
    }
    
    public function getPrivateChallengesForUser(){
        $input = ( $_POST ? $_POST : $_GET );
        if (isset($input['userID'])){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUser($input['userID'], TRUE); // true means get private challenge only
        }
    }
    
    /*
     * returns all challeneges including those without an opponent
     */
    public function getPublicChallenges(){
        return $this->getPublic();
    }
    
    /*
     * returns all challeneges including those without an opponent
     */
    public function getPrivateChallenges(){
        return $this->getPrivate();
    }
    
    
    /*
     * returns all challeneges including those without an opponent
     */
    public function getPublic(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if ( !empty( $input->userID ) ){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallenges( $input->userID );
        }
    }
    
    /*
     * returns all challeneges including those without an opponent
     */
    public function getPrivate(){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if ( !empty( $input->userID ) ){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallenges( $input->userID, TRUE ); // true means get private challenge only
        }
    }
    
    public function getPrivateChallengesForUserBeforeDate(){
        $input = ( $_POST ? $_POST : $_GET );
        if (isset($input['userID']) && isset($input['prevIDs']) && isset($input['datetime'])){
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUserBeforeDate($input['userID'], $input['prevIDs'], $input['datetime'], TRUE); // true means get private challenges only
        }
    }
    
    public function submitMatchingChallenge(){
        $uv = null;
        $input = (object) ( $_POST ? $_POST : $_GET );
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL)){
            $thisFunc = array( __CLASS__, __FUNCTION__ );
            $expires = $this->resolveExpires();
            if( $this->useQueue( $thisFunc ) ){
                $jobs = new BIM_Jobs_Challenges();
                $uv = $jobs->queueSubmitMatchingChallengeJob( $input->userID, $input->subject, $input->imgURL, $expires );
            }
            if( !$uv ){
                $challenges = new BIM_App_Challenges();
                $uv = $challenges->submitMatchingChallenge( $input->userID, $input->subject, $input->imgURL, $expires );
                $this->queueStaticPagesJobs();
               }
        }
        return $uv;
    }
    
    protected function resolveExpires(){
        $input = (object) ($_POST ? $_POST : $_GET );
        $expires = !empty( $input->expires ) ? $input->expires : 1;
        $expireTime = -1;
        $time = time();
        if( $expires == 2 ){
            $expireTime = $time + 600;
        } else if( $expires == 3 ){
            $expireTime = $time + 86400;
        }
        return $expireTime;
    }
    
    public function flagChallenge(){
        $uv = null;
        if ( isset($_POST['userID']) && isset($_POST['challengeID']) ){
            $thisFunc = array( __CLASS__, __FUNCTION__ );
            if( $this->useQueue( $thisFunc ) ){
                $jobs = new BIM_Jobs_Challenges();
                $uv = $jobs->queueFlagChallengeJob( $_POST['userID'], $_POST['challengeID'] );
            }
            if( !$uv ){
                $challenges = new BIM_App_Challenges();
                $uv = $challenges->flagChallenge( $_POST['userID'], $_POST['challengeID'] );
                $this->queueStaticPagesJobs();
               }
        }
        return $uv;
    }
    
    public function cancelChallenge(){
        $uv = null;
        if (isset($_POST['challengeID'])) {
            $thisFunc = array( __CLASS__, __FUNCTION__ );
            if( $this->useQueue( $thisFunc ) ){
                $jobs = new BIM_Jobs_Challenges();
                $uv = $jobs->queueCancelChallengeJob( $_POST['challengeID'] );
            }
            if( !$uv ){
                $challenges = new BIM_App_Challenges();
                $uv = $challenges->cancelChallenge( $_POST['challengeID'] );
                $this->queueStaticPagesJobs();
            }
        }
        return array(
            'id' => $uv->id
        );
    }
    
    public function acceptChallenge(){
        $uv = null;
        if (isset( $_POST['userID']) && isset($_POST['challengeID']) && isset($_POST['imgURL'])) {
            $thisFunc = array( __CLASS__, __FUNCTION__ );
            if( $this->useQueue( $thisFunc ) ){
                $jobs = new BIM_Jobs_Challenges();
                $uv = $jobs->queueAcceptChallengeJob( $_POST['userID'], $_POST['challengeID'], $_POST['imgURL'] );
            }
            if( !$uv ){
                $challenges = new BIM_App_Challenges();
                $uv = $challenges->acceptChallenge( $_POST['userID'], $_POST['challengeID'], $_POST['imgURL'] );
                $this->queueStaticPagesJobs();
               }
        }
        return array(
            'id' => $uv->id
        );
    }
    
    public function submitChallengeWithUsernames(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL) && isset($input->usernames)){
            $usernames = explode('|', $input->usernames );
            $expires = $this->resolveExpires();
            $isPrivate = !empty( $input->isPrivate ) ? $input->isPrivate : 'N' ;
            foreach( $usernames as $username ){
                $uv = null;
                $func = array( __CLASS__, 'submitChallengeWithUsername' );
                if( $this->useQueue( $func ) ){
                    $jobs = new BIM_Jobs_Challenges();
                    $uv = $jobs->queueSubmitChallengeWithUsernameJob( $input->userID, $input->subject, $input->imgURL, $username, $isPrivate, $expires );
                }
                if( !$uv ){
                    $challenges = new BIM_App_Challenges();
                    $uv = $challenges->submitChallengeWithUsername( $input->userID, $input->subject, $input->imgURL, $username, $isPrivate, $expires );
                    $this->queueStaticPagesJobs();
                }
            }
        }
        return $uv;
    }
    
    public function submitChallengeWithUsername(){
        $input = $_POST ? $_POST : $_GET;
        $uv = null;
        if (isset($input['userID']) && isset($input['subject']) && isset($input['imgURL']) && isset($input['username'])){
            $isPrivate = !empty( $input['isPrivate'] ) ? $input['isPrivate'] : 'N' ;
            $thisFunc = array( __CLASS__, __FUNCTION__ );
            $expires = $this->resolveExpires();
            if( $this->useQueue( $thisFunc ) ){
                $jobs = new BIM_Jobs_Challenges();
                $uv = $jobs->queueSubmitChallengeWithUsernameJob( $input['userID'], $input['subject'], $input['imgURL'], $input['username'], $isPrivate, $expires );
            }
            if( !$uv ){
                $challenges = new BIM_App_Challenges();
                $uv = $challenges->submitChallengeWithUsername( $input['userID'], $input['subject'], $input['imgURL'], $input['username'], $isPrivate, $expires  );
                $this->queueStaticPagesJobs();
            }
        }
        return $uv;
    }
    
    public function get(){
        $input = $_POST ? $_POST : $_GET;
        $challenge = array();
        if( isset( $input['challengeID'] ) ){
            $challenges = new BIM_App_Challenges();
            $challenge = $challenges->getChallengeObj( $input['challengeID'] );
        }
        return $challenge;
    }
    
    protected function queueStaticPagesJobs(){
        return;
        $voteJobs = new BIM_Jobs_Votes();
        $voteJobs->queueStaticChallengesByDate();
        $voteJobs->queueStaticChallengesByActivity();
        $voteJobs->queueStaticTopChallengesByVotes();
    }
}
