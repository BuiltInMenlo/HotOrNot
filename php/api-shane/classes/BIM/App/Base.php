<?php 

class BIM_App_Base{
    
	protected static $users = array();
	
    public static function getUser( $userId ){
        if( empty( self::$users[$userId] ) ){
            $user = BIM_Model_User::get( $userId );
            if ( !$user || ! $user->isExtant() ){
                self::$users[$userId] = false;
            } else {
                self::$users[$userId] = $user;
            }
        }
        return self::$users[$userId];
    }
}