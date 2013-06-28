<?php

class BIM_Controller_Social extends BIM_Controller_Base {
    
    public function addFriend( ){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if( ( !empty($input->target ) && !empty( $input->userID ) ) && ( $input->target != $input->userID ) ){
            return BIM_App_Social::addfriend( $input );
        }
        return array();
    }
    
    public function acceptfriend( ){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if( !empty($input->source ) && !empty( $input->userID ) ){
            return BIM_App_Social::acceptFriend( $input );
        }
        return array();
    }
    
    public function removefriend( ){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if( !empty($input->target ) && !empty( $input->userID ) ){
            return BIM_App_Social::removeFriend( $input );
        }
        return array();
    }
    
    public function getFriends( ){
        $input = (object) ( $_POST ? $_POST : $_GET );
        if( !empty( $input->userID ) ){
            return BIM_App_Social::getFriends( $input );
        }
        return array();
    }
}
