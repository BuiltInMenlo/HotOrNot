<?php 

class BIM_Report{
    // get the top 50 users that have been suspended
    // and get the top 50 that are about to be suspended
    
    public static function carlosDanger(){
        echo("
        <html>
        <head>
        </head>
        <body>
        ");
        
        echo("
        <table>
        ");
        $users = BIM_Model_User::getSuspendees();
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td>$user->img_url</td>
                <td>$user->username</td>
                <td>$flagCounts->flags</td>
                <td>$flagCounts->approves</td>
                <td>$user->abuse_ct</td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        ");
        
        echo("
        <table>
        ");
        $users = BIM_Model_User::getPendingSuspendees();
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td>$user->img_url</td>
                <td>$user->username</td>
                <td>$flagCounts->flags</td>
                <td>$flagCounts->approves</td>
                <td>$user->abuse_ct</td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        ");
        
        echo("
        </body>
        </html>
        ");
    }
}