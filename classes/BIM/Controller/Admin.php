<?php 
class BIM_Controller_Admin{
    
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
        
        $volleys = BIM_Model_Volley::getTopVolleysByVotes();
        $rem = array();
        $volleyArr = $volleys;
        foreach( $volleyArr as $idx => $volley ){
            if( in_array( $volley->id, $volleyIds ) ){
                unset( $volleys[ $volley->id ] );
            }
        }
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
        $volleys = $v->getChallengesByDate();
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