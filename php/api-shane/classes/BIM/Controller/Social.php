<?php

class BIM_Controller_Social extends BIM_Controller_Base {
    
    public function addFriend( ){
        if( ( isset($_GET['target'] ) && isset( $_GET['userID'] ) ) && ( $_GET['target'] != $_GET['userID'] ) ){
            return BIM_App_Social::addfriend( (object) $_GET );
        }
        return array();
    }
    
    public function acceptfriend( ){
        if( isset($_GET['source'] ) && isset( $_GET['userID'] )){
            return BIM_App_Social::acceptFriend( (object) $_GET );
        }
        return array();
    }
    
    public function removefriend( ){
        if( isset($_GET['target'] ) && isset( $_GET['userID'] ) ){
            return BIM_App_Social::removeFriend( (object) $_GET );
        }
        return array();
    }
    
    public function getFriends( ){
        if( isset( $_GET['userID'] ) ){
            return BIM_App_Social::getFriends( (object) $_GET );
        }
        return array();
    }
}
