<?php
require_once 'vendor/autoload.php';

$conf123ErrMsg = '';
$conf123 = BIM_App_Config::getBootConf( array('type' => '123') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['123'] );
    if( $data ){
        $params = array(
            'type' => '123',
            'data' => $data,
        );
        $conf123 = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf123ErrMsg = "Bad input for the 123 boot confg!  Please make sure it is valid JSON!";
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
123 Boot Configuration
<br>
<?php if( $conf123ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf123ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="123"><?php echo $conf123 ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>