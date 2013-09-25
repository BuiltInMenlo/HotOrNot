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
        
        $users = BIM_Model_User::getSuspendees();
        echo "<hr>Suspended - ".count( $users )."<hr>\n";
        
        echo("
        <table border=1 cellpadding=10>
        <tr>
        <th>Image</th>
        <th>Username</th>
        <th>Age</th>
        <th>Flags</th>
        <th>Approvals</th>
        <th>Abuse Count</th>
        </tr>
        ");
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $datetime1 = new DateTime();
                $datetime2 = new DateTime($user->age);
                $interval = $datetime1->diff($datetime2);
                $age = $interval->y;
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td><img src='$user->avatar_url'></td>
                <td>$user->username</td>
                <td>$age</td>
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
        
        $users = BIM_Model_User::getPendingSuspendees();
        echo "<hr>Pending - ".count( $users )."<hr>\n";
        
        echo("
        <table border=1 cellpadding=10>
        <tr>
        <th>Image</th>
        <th>Username</th>
        <th>Age</th>
        <th>Flags</th>
        <th>Approvals</th>
        <th>Abuse Count</th>
        </tr>
        ");
        // now get the flag counts for each user
        foreach( $users as $user ){
            $vv = BIM_Model_Volley::getVerifyVolley($user->id);
            if( $vv->isExtant() ){
                $datetime1 = new DateTime();
                $datetime2 = new DateTime($user->age);
                $interval = $datetime1->diff($datetime2);
                $age = $interval->y;
                $flagCounts = $vv->getFlagCounts();
                echo "
                <tr>
                <td><img src='$user->avatar_url'></td>
                <td>$user->username</td>
                <td>$age</td>
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
    
    public static function printStats(){
        $totalUsers = self::getTotalUsers();
    }
    
/**
Total number of users
*/

    public static function getTotalUsers(){
        $sql = "select count(*) from `hotornot-dev`.tblUsers";
        $dao = new BIM_DAO_Mysql( BIM_Config::db() );
        $stmt = $dao->prepareAndExecute( $sql );
        return $stmt->fetchColumn(0);
    }
    
/**
Total number of unique daily actives
*/
    public static function getActiveUsers( $type ){
        $sql = "select count(*) from `hotornot-dev`.tblUsers";
        $dao = new BIM_DAO_Mysql( BIM_Config::db() );
        $stmt = $dao->prepareAndExecute( $sql );
        return $stmt->fetchColumn(0);
    }

/**
Avg. number of mins per user per day
*/

/**
Number of Volleys create per day total
*/

/**
Number of Volleys per day per user avg.
*/
/**
Number of Joins per day total
*/
/**
Number of Joins per day per user avg.
*/
/**
Number of Verified users total
*/
/**
Number of Verified users per day
*/
/**
Number of Not Verified users total
*/
/**
Number of Not Verified users per day
*/
/**
Numbers of Verify Suspensions total
*/
/**
Numbers of Verify Suspensions per day
*/
/**
Number of flags per day
*/
/**
Number of likes per day total
*/
/**
Number of likes per day per user avg.
*/
/**
Number of subscribes per day total
*/
/**
Number of subscribers per user avg.
*/
/**
Top subscribed user (user with the most subscribed users)
*/
/**
Top subscriptions user (user with the most subscriptions)
 */
    
}