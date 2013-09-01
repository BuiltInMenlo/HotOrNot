<?php

class BIM_Controller_Social extends BIM_Controller_Base {
    
    public function addFriend( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( ( !empty($input->target ) && !empty( $input->userID ) ) && ( $input->target != $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::addFriend( $input );
        }
        return array();
    }
    
    public function acceptFriend( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty($input->source ) && !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::acceptFriend( $input );
        }
        return array();
    }
    
    public function removeFriend( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty($input->target ) && !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::removeFriend( $input );
        }
        return array();
    }
    
    public function getFriends( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::getFriends( $input );
        }
        return array();
    }
    
    public function getSubscribees( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( !empty( $input->userID ) ){
            $input->userID = $this->resolveUserId( $input->userID );
            return BIM_App_Social::getFollowed( $input );
        }
        return array();
    }
}
