<?php 
class BIM_App_Admin{
    
    /**
     * if we are receiving a posted image
     * first we upload the image to s3
     * then we generate the small images
     * then we write the volley
     * 
     * and redirect the user back to the create page
     * 
     * if we do not receive a posted image
     * we just simply print the form and the volleys beneath it
     * 
     */
    
    public static function createVolley(){
        $input = (object)( $_POST? $_POST : $_GET);
        
        if( !empty( $_FILES['image'] ) ){
            $image = new Imagick( $_FILES['image']['tmp_name'] );
            $conf = BIM_Config::aws();
            S3::setAuth($conf->access_key, $conf->secret_key);
            $namePrefix = 'TV_Volley_Image-'.uniqid(true);
            $name = "{$namePrefix}Large_640x1136.jpg";
            $imgUrlPrefix = "https://d1fqnfrnudpaz6.cloudfront.net/$namePrefix";
            S3::putObjectString($image->getImageBlob(), 'hotornot-challenges', $name, S3::ACL_PUBLIC_READ, array(), 'image/jpeg' );
            BIM_Utils::processImage($imgUrlPrefix);
            
            //BIM_Model_Volley::create( 2394, $input->hashtag, $imgUrlPrefix );
        }
        
        echo("
        <html>
        <head>
		<script src='http://code.jquery.com/jquery-1.10.1.min.js'></script>
        </head>
        <body>
        ");
        
        $volleys = BIM_Model_Volley::getVolleys(2394);
        
        echo("
        Create a new Volley for Team Volley
        <br><br>
		<form method='post'enctype='multipart/form-data'>
        	Hash Tag: <input type='text' size='100' name='hashtag'>
        	<br>
			Volley Image: <input type='file' name='image'>
			<br>
        <input type='submit'>
        
        </form>
        
		<hr>Team Volley volleys - ".count( $volleys )."<hr>\n
        <table border=1 cellpadding=10>
        <tr>
        <th>Volley Id</th>
        <th>Image</th>
        <th>Creator</th>
        <th>Hash Tag</th>
        <th>Challengers</th>
        <th>Creation Date</th>
        <th>Last Updated</th>
        </tr>
        ");
        // now get the flag counts for each user
        foreach( $volleys as $volley ){
            $creator = $volley->creator;
            $totalChallengers = count($volley->challengers);
            $img = $volley->getCreatorImage();
            if( $volley->isExtant() ){
                echo "
                <tr>
                <td>$volley->id</td>
                <td><img src='$img'></td>
                <td>$creator->username</td>
                <td>$volley->subject</td>
                <td>$totalChallengers</td>
                <td>$volley->added</td>
                <td>$volley->updated</td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        </body>
        </html>
        ");
        exit;
    }
    
    /**
     * We present a formn with the top 100 voleys by date 
     * 
     * There will be a drop down that alows for changing the 
     * view using sorted by top votes
     * 
     * There will be a check box next to each volley description
     * submitting the form will cause the volley ids to go into a table
     * 
     * The discover code will select all of the ids from this table
     * and get 16 random ones and retunr the volleys like normal
     * 
     */
    
    public static function manageExplore(){
        $input = (object)( $_POST? $_POST : $_GET);
        $volleyIds = array();
        if( property_exists($input, 'volleyIds') || (!empty( $_SERVER['REQUEST_METHOD'] ) && strtolower( $_SERVER['REQUEST_METHOD'] ) == 'post' ) ){
            $volleyIds = !empty($input->volleyIds) ? $input->volleyIds : array();
            $volleyData = array();
            foreach( $volleyIds as $volleyId ){
                $volley = BIM_Model_Volley::get( $volleyId );
                if( $volley->isExtant() ){
                    $volleyData[] = $volley;
                }
            }
            BIM_Model_Volley::updateExploreIds( $volleyData );
        } else {
            $volleyIds = BIM_Model_Volley::getExploreIds();
        }
        echo("
        <html>
        <head>
		<script src='http://code.jquery.com/jquery-1.10.1.min.js'></script>
        <script type='text/javascript'>
        	function clearAll(){
        		$('[name=\"volleyIds[]\"]').each(function(index,el){ $(el).prop('checked',false);} )
        	}
        </script>
        </head>
        <body>
        ");
        
        // $volleys = BIM_Model_Volley::getTopVolleysByVotes();
        $volleys = BIM_Model_Volley::getTopVolleysByVotes( 86400 * 30 );
        //$rem = array();
        //$volleyArr = $volleys;
        //foreach( $volleyArr as $idx => $volley ){
          //  if( in_array( $volley->id, $volleyIds ) ){
            //    unset( $volleys[ $volley->id ] );
            //}
        //}
        // $volleys = array_diff( $volleys, $volleyIds );
        echo "<hr>Top Volleys By Likes - ".count( $volleys )."&nbsp;&nbsp;<a href='#recent'>Most Recent</a><hr>\n";
        
        echo("
        <form method='POST'>
        <input type='submit'>
        <table border=1 cellpadding=10>
        <tr>
        <th>Volley Id</th>
        <th>Image</th>
        <th>Creator</th>
        <th>Hash Tag</th>
        <th>Challengers</th>
        <th>Creation Date</th>
        <th>Last Updated</th>
        <th>Display <input type='button' value='clear' onClick='clearAll();'></th>
        </tr>
        ");
        // now get the flag counts for each user
        foreach( $volleys as $volley ){
            $creator = $volley->creator;
            $totalChallengers = count($volley->challengers);
            $img = $volley->getCreatorImage();
            $checked = in_array( $volley->id, $volleyIds ) ? ' checked ' : '';
            if( $volley->isExtant() ){
                echo "
                <tr>
                <td>$volley->id</td>
                <td><img src='$img'></td>
                <td>$creator->username</td>
                <td>$volley->subject</td>
                <td>$totalChallengers</td>
                <td>$volley->added</td>
                <td>$volley->updated</td>
                <td><input type='checkbox' $checked name='volleyIds[]' value='$volley->id'></td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        ");
        
        $v = new BIM_App_Votes();
        $volleys = $v->getChallengesByCreationTime();
        echo "<hr><a id='recent'>Most Recent Volleys - ".count( $volleys )."</a><hr>\n";
        
        echo("
        <table border=1 cellpadding=10>
        <tr>
        <th>Volley Id</th>
        <th>Image</th>
        <th>Creator</th>
        <th>Hash Tag</th>
        <th>Challengers</th>
        <th>Creation Date</th>
        <th>Last Updated</th>
        <th>Display</th>
        </tr>
        ");
        // now get the flag counts for each user
        foreach( $volleys as $volley ){
            $creator = $volley->creator;
            $totalChallengers = count($volley->challengers);
            $img = $volley->getCreatorImage();
            $checked = in_array( $volley->id, $volleyIds ) ? ' checked ' : '';
            if( $volley->isExtant() ){
                echo "
                <tr>
                <td>$volley->id</td>
                <td><img src='$img'></td>
                <td>$creator->username</td>
                <td>$volley->subject</td>
                <td>$totalChallengers</td>
                <td>$volley->added</td>
                <td>$volley->updated</td>
                <td><input type='checkbox' $checked name='volleyIds[]' value='$volley->id'></td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        ");
         echo("
        <input type='submit'>
        </form>
        </body>
        </html>
        ");
        exit;
    }
    
}