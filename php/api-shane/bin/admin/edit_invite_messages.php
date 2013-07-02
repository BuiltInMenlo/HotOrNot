<?php
require_once 'vendor/autoload.php';

$msgs = (object) BIM_Config::inviteMsgs();
$sms = !empty($msgs->sms) ? $msgs->sms : '';
$email = !empty($msgs->email) ? $msgs->email : '';

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    $params = (object) array();
    
    $sms = trim( $_POST['sms'] );
    if( $sms ){
        $params->sms = $sms;
    }
    
    $email = trim( $_POST['email'] );
    if( $email ){
        $params->email = $email;
    }
    
    BIM_Config::saveInviteMsgs($params);
            
}

?>

<html>
<head>
<title>
Edit SMS and Email Invite Text
</title>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.0.min.js"></script>
</head>
<body>
<form method="post">
<table>
<tr>
<td>
SMS Invite Message
<br>
<textarea rows="25" cols="50" name="sms"><?php echo $sms ?></textarea>
</td>
<td>
Email Invite Message
<br>
<textarea rows="25" cols="50" name="email"><?php echo $email ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>