<?php
require_once 'vendor/autoload.php';

$confErrMsg = '';
$ptrn = '@^.*?/boot/edit/(\w+).*?$@';

$requestPath = $_SERVER['REQUEST_URI'];
if( preg_match( $ptrn, $requestPath) ){
    $build = preg_replace($ptrn, '$1', $requestPath);
    $conf = BIM_App_Config::getBootConf( array('type' => $build) );
    
    $method = strtolower( $_SERVER['REQUEST_METHOD'] );
    
    if( $method == 'post' ) {
        
        $data = trim( $_POST[$build] );
        if( $data ){
            $params = array(
                'type' => $build,
                'data' => $data,
            );
            $conf = $data;
            if( ! BIM_App_Config::saveBootConf( $params ) ){
                $confErrMsg = "Bad input for the $build boot confg!  Please make sure it is valid JSON!";
            }
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
<?php echo $build; ?> Boot Configuration
<br>
<?php if( $confErrMsg ) {?> <span style="color: red;"><b><?php echo $confErrMsg;?></b></span><br><?php }?>
<textarea rows="25" cols="100" name="<?php echo $build;?>"><?php echo $conf ?></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
</body>
</html>
