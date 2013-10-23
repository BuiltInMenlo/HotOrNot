<?php
require_once 'vendor/autoload.php';

$conf200ErrMsg = '';
$conf200 = BIM_App_Config::getBootConf( array('type' => '200') );

$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    
    $data = trim( $_POST['200'] );
    if( $data ){
        $params = array(
            'type' => '200',
            'data' => $data,
        );
        $conf200 = $data;
        if( ! BIM_App_Config::saveBootConf( $params ) ){
            $conf200ErrMsg = "Bad input for the 200 boot confg!  Please make sure it is valid JSON!";
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
200 Boot Configuration
<br>
<?php if( $conf200ErrMsg ) {?> <span style="color: red;"><b><?php echo $conf200ErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="50" name="200"><?php echo $conf200 ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>