<?php 
class BIM_Maint_Volley{
    public static function resizeVolleyImages(){
		$dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
		$sql = "select id from hotornot-dev.tblChallenges where added > '2013-07-12'";
		$stmt = $dao->prepareAndExecute( $sql );
        $volleyIds = $stmt->fecthAll(PDO::FETCH_COLUMN, 0);
        while( $volleyIds ){
            $ids = array_splice($volleyIds, 0, 250);
            $volleys = self::getMulti($ids);
            self::convertImage( $volley->creator->img );
            print count( $volleyIds )." remaining\n";
        }
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
    public static function convertImage( $imgPath ){
        
    }
    
    public static function resizeImage( $imgFilePath ){
        $percent = 0.5;
        
        // Get new dimensions
        list($width, $height) = getimagesize($imgFilePath);
        
        print_r( array($width, $height) );
        
        $new_width = 1136;
        $new_height = 1136;
        
        // Resample
        $image_p = imagecreatetruecolor($new_width, $new_height);
        $image = imagecreatefromjpeg($imgFilePath);
        imagecopyresampled($image_p, $image, 0, 0, 0, 0, $new_width, $new_height, $width, $height);
        
        $new_height = 1136;
        $new_width = 640;
        
        $x = (int) ($new_width - $new_height)/2;
        $params = array(
            'x' => $x,
            'y' => 0,
            'width' => 640,
            'height' => $new_height,
        );
        imagecrop( $image_p, $params );
        
        // Output
        imagejpeg($image_p, null, 100);
    }
}