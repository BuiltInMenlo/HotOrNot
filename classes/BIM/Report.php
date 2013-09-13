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
        
        echo "<hr>Suspended<hr>\n";
        
        echo("
        <table border=1 cellpadding=10>
        <tr>
        <th>Image</th>
        <th>Username</th>
        <th>Flags</th>
        <th>Approvals</th>
        <th>Abuse Count</th>
        </tr>
        ");
        $users = BIM_Model_User::getSuspendees();
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td><img src='$user->avatar_url'></td>
                <td>$user->username</td>
                <td>$flagCounts->flags</td>
                <td>$flagCounts->approves</td>
                <td>$flagCounts->abuse_ct</td>
                </tr>
                ";
            }
        }
        echo("
        </table>
        ");
        
        echo "<hr>Pending<hr>\n";
        
        echo("
        <table border=1 cellpadding=10>
        <tr>
        <th>Image</th>
        <th>Username</th>
        <th>Flags</th>
        <th>Approvals</th>
        <th>Abuse Count</th>
        </tr>
        ");
        $users = BIM_Model_User::getPendingSuspendees();
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td><img src='$user->avatar_url'></td>
                <td>$user->username</td>
                <td>$flagCounts->flags</td>
                <td>$flagCounts->approves</td>
                <td>$flagCounts->abuse_ct</td>
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