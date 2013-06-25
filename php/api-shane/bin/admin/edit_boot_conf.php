<?php
require_once 'vendor/autoload.php';

$liveErrMsg = '';
$liveConf = BIM_App_Config::getBootConf( array('type' => 'live') );

$devErrMsg = '';
$devConf = BIM_App_Config::getBootConf( array('type' => 'dev') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $live = trim( $_POST['live'] );
    if( $live ){
        $params = array(
            'type' => 'live',
            'data' => $live,
        );
        $liveConf = $live;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $liveErrMsg = "Bad input for the live boot confg!  Please make sure it is valid JSON!";
        }
    }
    
    $dev = trim( $_POST['dev'] );
    if( $dev ){
        $params = array(
            'type' => 'dev',
            'data' => $dev,
        );
        $devConf = $dev;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $devErrMsg = "Bad input for the dev boot confg!  Please make sure it is valid JSON!";
        }
    }
        
}

?>

<html>
<head>
<title>
Edit The Boot Configuration
</title>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.0.min.js"></script>
</head>
<body>
<form method="post">
<table>
<tr>
<td>
Live Boot Configuration
<br>
<?php if( $liveErrMsg ) {?> <span style="color: red;"><b><?php echo $liveErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="live"><?php echo $liveConf ?></textarea>
</td>
<td>
Dev Boot Configuration
<br>
<?php if( $devErrMsg ){ ?> <span style="color: red;"><b><?php echo $devErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="dev"><?php echo $devConf ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>