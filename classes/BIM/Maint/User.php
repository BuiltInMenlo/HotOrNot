<?php 
class BIM_Maint_User{
    
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
            $userId = $hit->_source->source;
            $user = BIM_Model_User::get( $userId );
            if( ! $user->isExtant() ){
                print_r( array("removing",$hit) );
                $dao->removeRelation( $hit->_source );
            } else {
                $userId = $hit->_source->target;
                $user = BIM_Model_User::get( $userId );
                if( !$user->isExtant() ){
                    print_r( array("removing",$hit) );
                    $dao->removeRelation($hit->_source);
                } else {
                    print_r( array("retaining",$hit) );
                }
            }
        }
    }
}