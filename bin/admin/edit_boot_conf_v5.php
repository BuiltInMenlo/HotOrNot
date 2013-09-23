<?php
require_once 'vendor/autoload.php';

$conf125ErrMsg = '';
$conf125 = BIM_App_Config::getBootConf( array('type' => '125') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['125'] );
    if( $data ){
        $params = array(
            'type' => '125',
            'data' => $data,
        );
        $conf125 = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf125ErrMsg = "Bad input for the 125 boot confg!  Please make sure it is valid JSON!";
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
125 Boot Configuration
<br>
<?php if( $conf125ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf125ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="125"><?php echo $conf125 ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>