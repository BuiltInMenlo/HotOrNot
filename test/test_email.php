<?php
require_once 'vendor/autoload.php';

$list = array(
    'kingl33@me.com',
    'allisongailmills@gmail.com',
    'benjik@gmail.com',
    'bjaxsoccerboy10@gmail.com',
    'brayden.ritchie.1@live.ca',
    'cback343@aol.com',
    'devlinjrocha@gmail.com',
    'hannett.garrett@yahoo.com',
    'flmfao@yahoo.com',
    'jsol420@gmail.com',
    'kalei6@yahoo.com',
    'Kasianajdek@me.com',
    'madelinetuazon@gmail.com',
    'manideosu@gmail.com',
    'deminator567845@yahoo.com',
    'rayne@raynemark.com',
    'ryan.orbuch@gmail.com',
    'ryenab@gmail.com',
    'shahedkhan30@gmail.com',
    'shriram.gajjar@yahoo.com',
    'sotidas0.0@gmail.com',
    '3d.gamer1337@gmail.com',
    'Sharona.sewell001@gmail.com',
    'flmfao@yahoo.com',
    'njbear721@gmail.com',
    'Bjaxsoccerboy10@gmail.com',
    'redsantana98@gmail.com',
    'p.seng7351@gmail.com',
    'Deminator567845@yahoo.com',
    'Music4ca@yahoo.com',
    'valeriaa1220@gmail.com',
    'Yungsid528@gmail.com',
    'stephandcinnamon@aol.com',
    'Brayden.ritchie.1@live.ca',
    'Miguelayala40@gmail.com',
    'Evelynmendez56@gmail.com',
    'giofparedes@gmail.com',
    'p.seng7351@gmail.com',
    'steven.shatkin@gmail.com',
	'shane@shanehill.com',
    'jasonfesta82@gmail.com',
    'matt.holcombe@gmail.com'
);

$emailData = (object) array(
	'to_email' => '',
	'from_email' => 'shane@shanehill.com',
	'from_name' => 'Built In Menlo',
	'subject' => 'Thanks for installing Volley!',
	'text' => 
'
Thanks for installing! 

Please take the following survey: http://bit.ly/volleyfocusgroup

Once the survey is complete we will process your answers & reward. Please let us know if you have any questions or comments!

-TeamVolley (support@letsvolley.com)

www.letsvolley.com

You are receiving this email because you asked to be notified about Volley.
To unsubscribe from these notifications, send an email to unsubscribe@builtinmenlo.com

',
);

$c = (object) array(
    'host' => 'smtp.mandrillapp.com',
    'port' => 587,
    'username' => 'apps@builtinmenlo.com',
    'password' => 'JW-zqg_yVLs7suuVBwG_xw'
);

$e = new BIM_Email_Swift( $c );

$list = array('alerts@builtinmenlo.com');

foreach( $list as $addy ){
    $addy = trim( $addy );
    if( $addy ){
        $emailData->to_email = $addy;
        try{
            $e->sendEmail( $emailData );
            echo "sent to $addy\n";
            sleep(1);
        } catch ( Exception $ex ){
            print_r( $ex );
            echo "continuing\n";
        }
    }
}
