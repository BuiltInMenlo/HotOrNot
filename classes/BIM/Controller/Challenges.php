<?php

class BIM_Controller_Challenges extends BIM_Controller_Base {
    
    public function getChallengesForUserBeforeDate(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->prevIDs) && isset($input->datetime)){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUserBeforeDate( $userId, $input->prevIDs, $input->datetime);
        }
    }    
    
    public function submitChallengeWithChallenger(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL) && isset($input->challengerID)){
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $challengerIds = explode('|', $input->challengerID );
            $isPrivate = !empty( $input->isPrivate ) ? $input->isPrivate : 'N';
            $expires = $this->resolveExpires();
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges;
            return $challenges->submitChallengeWithChallenger( $userId, $input->subject, $input->imgURL, $challengerIds, $isPrivate, $expires );
        }
    }
    
    public function updatePreviewed(){
        // SECHOLE : needs a userid check
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->challengeID)){
            $challenges = new BIM_App_Challenges();
            $volley = $challenges->updatePreviewed($input->challengeID);
            return array(
                'id' => $volley->id
            );
        }
    }
    
    public function getPreviewForSubject(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->subjectName)){
            $challenges = new BIM_App_Challenges();
            return $challenges->getPreviewForSubject($input->subjectName);
        }
    }
    
    public function getAllChallengesForUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( isset( $input->userID ) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getAllChallengesForUser( $userId );
        }
    }

    public function getChallengesForUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUser( $userId );
        }
    }
    
    public function getPrivateChallengesForUser(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID)){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUser($userId, TRUE); // true means get private challenge only
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
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallenges( $userId );
        }
    }
    
    /*
     * returns all challeneges including those without an opponent
     */
    public function getPrivate(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty( $input->userID ) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallenges( $userId, TRUE ); // true means get private challenge only
        }
    }
    
    public function getPrivateChallengesForUserBeforeDate(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->prevIDs) && isset($input->datetime)){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            return $challenges->getChallengesForUserBeforeDate($userId, $input->prevIDs, $input->datetime, TRUE); // true means get private challenges only
        }
    }
    
    public function submitMatchingChallenge(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty($input->userID) && !empty($input->subject) && !empty($input->imgURL)){
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $userId = $this->resolveUserId( $input->userID );
            $expires = $this->resolveExpires();
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->submitMatchingChallenge( $userId, $input->subject, $input->imgURL, $expires );
        }
        return $uv;
    }
    
    protected function resolveExpires(){
        $input = (object) ($_POST ? $_POST : $_GET);
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
        $input = (object) ($_POST ? $_POST : $_GET);
        if ( !empty($input->userID) && !empty($input->challengeID) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->flagChallenge( $userId, $input->challengeID );
        }
        return $uv;
    }
    
    public function cancelChallenge(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->challengeID)) {
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->cancelChallenge( $input->challengeID );
        }
        if( $uv ){
            return array(
                'id' => $uv->id
            );
        }
    }
    
    public function acceptChallenge(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset( $input->userID) && isset($input->challengeID) && isset($input->imgURL)) {
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $input->userID  = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->acceptChallenge( $input->userID, $input->challengeID, $input->imgURL );
        }
        if( $uv ){
            return array(
                'id' => $uv->id
            );
        }
    }
    
    public function join(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (!empty( $input->userID) && !empty($input->challengeID) && !empty($input->imgURL)) {
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            // get the response hashtag
            $hashTag = empty( $input->subject ) ? '' : $input->subject; 
            $volley = BIM_Model_Volley::get( $input->challengeID );
            if( $volley->isExtant() ){
                $ptrn = "@$volley->subject\s*:@";
                $hashTag = trim(preg_replace( $ptrn, '', $hashTag, 1 ));           
                $uv = $challenges->join( $userId, $input->challengeID, $input->imgURL, $hashTag );
            }
        }
        if( $uv ){
            return array(
                'id' => $uv->id
            );
        }
    }
    
    public function create(){
        return $this->submitChallengeWithUsernames();
    }
    
    public function submitChallengeWithUsernames(){
        $uv = null;
        $input = (object) ($_POST ? $_POST : $_GET);
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL) ){
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $userId = $this->resolveUserId( $input->userID );
            $expires = $this->resolveExpires();
            $isPrivate = !empty( $input->isPrivate ) ? $input->isPrivate : 'N' ;
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->submitChallengeWithUsername( $userId, $input->subject, $input->imgURL, $isPrivate, $expires );
        }
        return $uv;
    }
    
    public function submitChallengeWithUsername(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $uv = null;
        if (isset($input->userID) && isset($input->subject) && isset($input->imgURL) ){
            $input->imgURL = $this->normalizeVolleyImgUrl($input->imgURL);
            $userId = $this->resolveUserId( $input->userID );
            $isPrivate = !empty( $input->isPrivate ) ? $input->isPrivate : 'N' ;
            $expires = $this->resolveExpires();
            $challenges = new BIM_App_Challenges();
            $uv = $challenges->submitChallengeWithUsername( $userId, $input->subject, $input->imgURL, $isPrivate, $expires  );
        }
        return $uv;
    }
    
    public function get(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $challenge = array();
        if( !empty( $input->challengeID ) ){
            $challenge = BIM_Model_Volley::get( $input->challengeID );
            if( !empty( $input->cancelFor ) ){
                BIM_Utils::cancelTimedPushes( $input->cancelFor, $input->challengeID );
            }
        }
        return $challenge;
    }
    
    /**
     * returns a list of verifyme volleys
     */
    public function getVerifyList(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $verifyList = array();
        if( isset( $input->userID ) ){
            $userId = $this->resolveUserId( $input->userID );
            $challenges = new BIM_App_Challenges();
            $verifyList = $challenges->getVerifyList( $userId );
        }
        return $verifyList;
    }
    
    public function missingImage(){
        $input = (object) ($_POST ? $_POST : $_GET);
        $fixed = false;
        if( isset( $input->imgURL ) ){
            $challenges = new BIM_App_Challenges();
            $fixed = $challenges->missingImage( $input->imgURL );
        }
        return $fixed;
    }
    
    public function processImage(){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->imgURL ) ){
            BIM_Jobs_Challenges::queueProcessImage( $input->imgURL);
        }
        return true;
    }
}
