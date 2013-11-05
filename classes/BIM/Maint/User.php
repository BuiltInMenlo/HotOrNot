<?php 
class BIM_Maint_User{
    
    public static function remindNewUsers(){
        $dao = new BIM_DAO_Mysql( BIM_Config::db() );
        $sql = "
        	select id 
        	from `hotornot-dev`.tblUsers 
        	where added > '2013-09-27'
        	and (img_url = '' or img_url is null)
        ";
        $stmt = $dao->prepareAndExecute($sql);
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
        $users = BIM_Model_User::getMulti($userIds);
        foreach( $users as $user ){
            echo "reminding $user->username : $user->id\n";
            BIM_Push::selfieReminder($user->id);
        }
    }
    
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
        $maxSubcribes = mt_rand(2,5);
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
            BIM_Push::introPush($userId, $targetId, $pushTime);
            $allSubscribees[ $targetId ]++;
            if( $allSubscribees[ $targetId ] >= $maxSubcribes ){
                unset($allSubscribees[ $targetId ]);
            }
            $pushTime += mt_rand( 2700, 7200 );
        }
        return $subscribeeIndexes;
    }
    
    /**
Final image sizes and where they are used
Timeline, Verify, Profile - 640x1136
Explore, My Profile - 320x320
Sub Details - 160x160

Flow/process...
Legacy image #1: 420x420 needs to go to 1136x1136 and then cropped out of the center to 640x1136 
Legacy image #2: 480x640 to 852x1136 and then cropped 640x1136
Legacy image #3: 960x1280 goes to 852x1136 and then cropped to 640x1136
Legacy image #4 200x200 goes to 1136x1136 and then cropped out of the center to 640x1136 
New non legacy images then will be scaled from 640x1136 to 320x568 then cropped to 320x320 followed by resizing to 160x160

Final suffix definitions.... 
Large_640x1136
Medium_320x320
Small_160x160
     * 
     */
    
    public static function convertUserImages(){
		$dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
		$sql = "select id from `hotornot-dev`.tblUsers where added > '2013-07-12'";
		$stmt = $dao->prepareAndExecute( $sql );
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
        self::convertUsers($userIds);
    }
    
    public static function convertUsers( $userIds ){
        $conf = BIM_Config::aws();
        S3::setAuth($conf->access_key, $conf->secret_key);
        while( $userIds ){
            $ids = array_splice($userIds, 0, 250);
            $users = BIM_Model_User::getMulti($ids);
            foreach( $users as $user ){
                if( !empty( $user->img_url ) ){
                    $imgPrefix = preg_replace('@\.jpg@','', $user->img_url );
                    self::processImage( $imgPrefix );
                    echo "processed user $user->id\n\n";
                }
            }
            print count( $userIds )." remaining\n\n====\n\n";
        }
    }
    
    public static function processImage( $imgPrefix, $bucket = 'hotornot-avatars' ){
        echo "converting $imgPrefix\n";
        $convertedImages = self::convertImage( $imgPrefix );
        if( $convertedImages ){
            $parts = parse_url( $imgPrefix );
            $path = trim($parts['path'] , '/');
            foreach( $convertedImages as $suffix => $image ){
                $name = "{$path}{$suffix}.jpg";
                S3::putObjectString($image->getImageBlob(), $bucket, $name, S3::ACL_PUBLIC_READ, array(), 'image/jpeg' );
                echo "put {$imgPrefix}{$suffix}.jpg\n";
            }
        }
    }
    
    public static function convertImage( $imgPrefix ){
        $image = self::getImage($imgPrefix);
        if( $image ){
            $width = $image->getImageWidth();
            $height = $image->getImageHeight();
            $convertedImages = array();
            if( $width == $height ){        
                $convertedImages = self::convert( $image, 1136, 1136, 640, 1136 );
            } else if( ($width == 480 && $height == 640) || ($width == 960 && $height == 1280) ){        
                $convertedImages = self::convert( $image, 852, 1136, 640, 1136 );
            } else {
                error_log("we have an odd image size $width x $height - $imgPrefix");
            }
        }
        return $convertedImages;
    }
    
    protected static function getImage( $imgPrefix ){
        $image = null;
        $imgUrl = "{$imgPrefix}_o.jpg";
        try{
            $image = new Imagick( $imgUrl );
        } catch ( Exception $e ){
            $msg = $e->getMessage()." - $imgUrl";
            error_log( $msg );
            $image = null;
            $imgUrl = "{$imgPrefix}.jpg";
            try{
                $image = new Imagick( $imgUrl );
            } catch( Exception $e ){
                $msg = $e->getMessage()." - $imgUrl";
                error_log( $msg );
                $image = null;
            }
        }
        echo "\n";
        return $image;
    }
    
    protected static function getImage2( $imgPrefix ){
        $image = null;
        $imgUrl = "{$imgPrefix}.jpg";
        try{
            $image = new Imagick( $imgUrl );
        } catch( Exception $e ){
            $msg = $e->getMessage()." - $imgUrl";
            error_log( $msg );
            $image = null;
        }
        return $image;
    }
    
    public static function convert( $image, $resizeWidth, $resizeHeight, $cropWidth, $cropHeight ){
        self::resize($image, $resizeWidth, $resizeHeight);
        self::cropX($image, $cropWidth, $cropHeight);
        $largeImage = clone $image;
        $convertedImages = self::finalizeImage($image);
        $convertedImages["Large_640x1136"] = $largeImage;
        return $convertedImages;
    }
    
    public static function finalizeImage( $image ){
        $convertedImages = array();
        
        self::resize($image, 320, 568);
        self::cropY($image, 320, 320);
        $mediumImage = clone $image;
        $convertedImages['Medium_320x320'] = $mediumImage;
        
        self::resize($image, 160, 160);
        $smallImage = clone $image;
        $convertedImages['Small_160x160'] = $smallImage;
        
        return $convertedImages;
    }
    
    public static function resize( $image, $width, $height ){
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution( $width, $height );
        $image->resizeImage($width, $height,imagick::FILTER_LANCZOS,0);
    }
    
    public static function cropX( $image, $width, $height ){
        $x = (int) ($image->getImageWidth() - $width)/2;
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution($width,$height);
        $image->cropImage($width, $height, $x, 0);
    }
    
    public static function cropY( $image, $width, $height ){
        $y = (int) ($image->getImageHeight() - $height)/2;
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution($width,$height);
        $image->cropImage($width, $height, 0, $y);
    }
    
    public static function removeDeadFriends(){
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        $docs = $dao->getFriendDocuments();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $sourceId = $hit->_source->source;
            $source = BIM_Model_User::get( $sourceId, true );
            if( ! $source->isExtant() ){
                print_r( array("removing",$hit) );
                $dao->removeRelation( $hit->_source );
            } else {
                $targetId = $hit->_source->target;
                $target = BIM_Model_User::get( $targetId, true );
                if( !$target->isExtant() ){
                    print_r( array("removing",$hit) );
                    $dao->removeRelation($hit->_source);
                } else {
                    // print_r( array("retaining",$hit) );
                }
            }
        }
    }
    
    public static function hashLists(){
        $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
        $docs = $dao->getPhoneLists();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            BIM_Utils::hashList( $list->hashed_list );
            $list->hashed_number = BIM_Utils::blowfishEncrypt( $list->hashed_number );
            
            $urlSuffix = "contact_lists/phone/$list->id";
            $added = $dao->call('PUT', $urlSuffix, $list);
            $addedData = json_decode( $added );
            if( isset( $addedData->ok ) && $addedData->ok ){
                echo "successfully hashed phone list for $list->id\n";
            } else {
                echo "could not hash phone list for $list->id - reason: $added\n";
            }
        }
        
        $docs = $dao->getEmailLists();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            BIM_Utils::hashList( $list->email_list );
            $list->email = BIM_Utils::blowfishEncrypt( $list->email );
            
            $urlSuffix = "contact_lists/email/$list->id";
            $added = $dao->call('PUT', $urlSuffix, $list);
            $addedData = json_decode( $added );
            if( isset( $addedData->ok ) && $addedData->ok ){
                echo "successfully hashed email list for $list->id\n";
            } else {
                echo "could not hash phone list for $list->id - reason: $added\n";
            }
        }
    
    }
    
    public static function copyLists(){
        $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
        $docs = $dao->getPhoneLists();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            $urlSuffix = "contact_lists_bkp/phone/$list->id";
            $added = $dao->call('PUT', $urlSuffix, $list);
            $addedData = json_decode( $added );
            if( isset( $addedData->ok ) && $addedData->ok ){
                echo "successfully copied phone list for $list->id\n";
            } else {
                echo "could not copy phone list for $list->id - reason: $added\n";
            }
        }
        
        $docs = $dao->getEmailLists();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            $urlSuffix = "contact_lists_bkp/email/$list->id";
            $added = $dao->call('PUT', $urlSuffix, $list);
            $addedData = json_decode( $added );
            if( isset( $addedData->ok ) && $addedData->ok ){
                echo "successfully copied email list for $list->id\n";
            } else {
                echo "could not copy phone list for $list->id - reason: $added\n";
            }
        }
    
    }
    
    public static function showHashedLists(){
        $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
        $docs = $dao->getPhoneLists_hashed();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            BIM_Utils::decryptList( $list->hashed_list );
            $list->hashed_number = BIM_Utils::blowfishDecrypt( $list->hashed_number );
            print_r( $list );            
        }
        
        $docs = $dao->getEmailLists_hashed();
        $docs = json_decode($docs);
        foreach( $docs->hits->hits as $hit ){
            $list = $hit->_source;
            BIM_Utils::decryptList( $list->email_list );
            $list->email = BIM_Utils::blowfishDecrypt( $list->email );
            print_r( $list );            
        }
    
    }
}