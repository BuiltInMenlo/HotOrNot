<?php 
class BIM_Maint_User{
    /**
     * we need to get all the user ids into 2 arrays
     * the arrays will be subcribees and subscribers
     * 
     * for each subscriber
     * we get their current list of subscribers
     * and we then subscribe to 5 users
     */
    public static function introduceUsersToEachOther(){
        $dao = new BIM_DAO_Mysql( BIM_Config::db() );
        $sql = "select id from `hotornot-dev`.tblUsers where added > '2013-09-08'";
        $stmt = $dao->prepareAndExecute($sql);
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
        $allSubscribees = array();
        foreach( $userIds as $userId ){
            $allSubscribees[ $userId ] = 0;
        }
        
        foreach( $userIds as $userId ){
            print_r( array( $userId, self::introduce( $userId, $allSubscribees ) ) );
            //exit();
        }
    }
    
    protected static function introduce( $userId, &$allSubscribees ){
        $maxSubcribes = 5;
        // get 5 random ids and subscribe to those
        
        // exclude the friends and ourselves
        $params = (object) array('userID' => $userId);
        $friends = BIM_App_Social::getFollowed($params);
        $searchArray = $allSubscribees;
        foreach( $friends as $friendRecord ){
            unset( $searchArray[ $friendRecord->user->id ] );
        }
        unset( $searchArray[ $userId ] );
        
        $subscribeeIndexes = array_rand($searchArray, $maxSubcribes);
        $user = BIM_Model_User::get( $userId );
        $pushTime = time();
        foreach( $subscribeeIndexes as $targetId ){
            $target = BIM_Model_User::get( $targetId );

            $params = (object) array(
                'userID' => $userId,
                'target' => $targetId,
            );
            BIM_App_Social::addFriend($params, false);
            $msg = "@$user->username has subscribed to your Volleys!";
            $push = array(
                "device_tokens" =>  array( $target->device_token ),
                "aps" =>  array(
                    "alert" =>  $msg,
                    "sound" =>  "push_01.caf"
                )
            );
            BIM_Push_UrbanAirship_Iphone::createTimedPush($push, $pushTime);
            $allSubscribees[ $targetId ]++;
            if( $allSubscribees[ $targetId ] >= $maxSubcribes ){
                unset($allSubscribees[ $targetId ]);
            }
            $pushTime += mt_rand( 1800, 3600 );
        }
        return $subscribeeIndexes;        
    }
}