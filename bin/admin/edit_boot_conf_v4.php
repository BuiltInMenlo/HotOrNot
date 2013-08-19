<?php
require_once 'vendor/autoload.php';

$conf124ErrMsg = '';
$conf124 = BIM_App_Config::getBootConf( array('type' => '124') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['124'] );
    if( $data ){
        $params = array(
            'type' => '124',
            'data' => $data,
        );
        $conf124 = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf124ErrMsg = "Bad input for the 124 boot confg!  Please make sure it is valid JSON!";
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
124 Boot Configuration
<br>
<?php if( $conf124ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf124ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="124"><?php echo $conf124 ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>