<?php
require_once 'vendor/autoload.php';

$conf130ErrMsg = '';
$build = BIM_App_Config::getBootConf( array('type' => '130') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['130'] );
    if( $data ){
        $params = array(
            'type' => '130',
            'data' => $data,
        );
        $build = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf130ErrMsg = "Bad input for the 130 boot confg!  Please make sure it is valid JSON!";
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
130 Boot Configuration
<br>
<?php if( $conf130ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf130ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="130"><?php echo $build ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>
