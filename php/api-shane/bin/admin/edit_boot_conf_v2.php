<?php
require_once 'vendor/autoload.php';

$conf122ErrMsg = '';
$conf122 = BIM_App_Config::getBootConf( array('type' => '122') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['122'] );
    if( $data ){
        $params = array(
            'type' => '122',
            'data' => $data,
        );
        $conf122 = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf122ErrMsg = "Bad input for the 122 boot confg!  Please make sure it is valid JSON!";
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
122 Boot Configuration
<br>
<?php if( $conf122ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf122ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="122"><?php echo $conf122 ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>