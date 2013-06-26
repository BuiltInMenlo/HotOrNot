<?php
require_once 'vendor/autoload.php';

foreach ( array(2383,881) as $id ){
    $workload = (object) array(
        'data' => (object) array(
            'user_id' => $id
        )
    );
    
    $j = new BIM_Jobs_Growth();
    
    $j->matchPush($workload);
}