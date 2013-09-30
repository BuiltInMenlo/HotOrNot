<?php 
class BIM_Maint_Volley{
    
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
    
    public static function convertVolleyImages(){
		$dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
		$sql = "select id from `hotornot-dev`.tblChallenges where added > '2013-07-12'";
		$stmt = $dao->prepareAndExecute( $sql );
        $volleyIds = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
        self::convertVolleys($volleyIds);
    }
    
    public static function convertVolleys( $volleyIds ){
        $conf = BIM_Config_Dynamic::aws();
        S3::setAuth($conf->access_key, $conf->secret_key);
        while( $volleyIds ){
            $ids = array_splice($volleyIds, 0, 250);
            $volleys = BIM_Model_Volley::getMulti($ids);
            foreach( $volleys as $volley ){
                self::processImage( $volley->creator->img );
                foreach( $volley->challengers as $challenger ){
                    self::processImage( $challenger->img );
                }
                echo "processed volley $volley->id\n\n";
            }
            print count( $volleyIds )." remaining\n\n====\n\n";
        }
    }
    
    public static function processImage( $imgPrefix, $bucket = 'hotornot-challenges' ){
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
            $imgUrl = "{$imgPrefix}_l.jpg";
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
    
    public static function convert( $image, $resizeWidth, $resizeHeight, $cropWidth, $cropHeight ){
        BIM_Utils::resize($image, $resizeWidth, $resizeHeight);
        BIM_Utils::cropX($image, $cropWidth, $cropHeight);
        $largeImage = clone $image;
        $convertedImages = BIM_Utils::finalizeImages($image);
        $convertedImages["Large_640x1136"] = $largeImage;
        return $convertedImages;
    }
}
