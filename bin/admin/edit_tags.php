<?php
require_once 'vendor/autoload.php';

$networks = array();

$dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
$tags = $dao->getTags();
$quotes = $dao->getQuotes();

$data = array();

foreach( $tags as $tag ){
    $o = json_decode($tag->tags);
    $data[ $tag->network ]['tags'][ $tag->type ] = join(',', $o );
}

foreach( $quotes as $quote ){
    $o = json_decode($quote->quotes);
    $data[ $quote->network ]['quotes'][ $quote->type ] = join(',', $o );
}
//print_r( array($quotes, $tags) );

foreach( $tags as $tag ){
    $networks[ $tag->network ] = 1;
}
$networks = array_keys($networks);


$method = strtolower( $_SERVER['REQUEST_METHOD'] );

if( $method == 'post' ) {
    if( $_POST['new_network'] ){
        $network = trim($_POST['new_network']);
    } else {
        $network = $_POST['network'];
    }
    
    if( trim($_POST['quotes_authentic']) ){
        $data = (object) array(
            'network' => $network,
            'type' => 'authentic',
            'quotes' => cleanInput( $_POST['quotes_authentic'] )
        );
        BIM_Config::saveQuotes($data);
    }
    
    if( trim($_POST['quotes_ad']) ){
        $data = (object) array(
            'network' => $network,
            'type' => 'ad',
            'quotes' => cleanInput($_POST['quotes_ad'])
        );
        BIM_Config::saveQuotes($data);
    }
    
    if( trim($_POST['quotes_other']) ){
        $data = (object) array(
            'network' => $network,
            'type' => 'other',
            'quotes' => cleanInput($_POST['quotes_other'])
        );
        BIM_Config::saveQuotes($data);
    }
    
    if( trim( $_POST['tags_authentic'] ) ){
        $data = (object) array(
            'network' => $network,
            'type' => 'authentic',
            'tags' => cleanInput($_POST['tags_authentic'])
        );
        BIM_Config::saveTags($data);
    }
    
    if( trim( $_POST['tags_ad'] ) ) {
        $data = (object) array(
            'network' => $network,
            'type' => 'ad',
            'tags' => cleanInput($_POST['tags_ad'])
        );
        BIM_Config::saveTags($data);
    }
    
    if( trim( $_POST['tags_other'] ) ) {
        $data = (object) array(
            'network' => $network,
            'type' => 'other',
            'tags' => cleanInput($_POST['tags_other'])
        );
        BIM_Config::saveTags($data);
    }
    
    if( $_POST['campaign']['create'] ){
        $_POST['campaign']['network'] = $_POST['network'];        
        BIM_Jobs_Growth::queueCreateCampaign( $_POST['campaign'] );
    }
    
    header('Location: edit_tags.php');
    exit();
}

function cleanInput( $data ){
    $data = trim( $data );
    $data = explode(',',$data);
    foreach( $data as &$el ){
        $el = trim( $el );
    }
    $data = join(',',$data);
    return $data;
}

?>

<html>
<head>
<title>
Edit Quotes and Tags
</title>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.0.min.js"></script>
</head>
<body>
<form method="post">
<table border=1 cellpadding=4>
<tr>
<td>
	Create a campaign <input type="checkbox" value="1" name="campaign[create]">
	<br>
	Insert a Volley hashtag <input type="text" name="campaign[link_freq]" size="5"> % of the time
	<br>
    Collect <input type="text" name="campaign[total_media]" size="5"> items for this campaign
</td>
</tr>
</table>
<br>
Apply the changes to this network:
<select name="network" id="network" onchange="populateForm()">
<?php foreach( $networks as $network ){ ?>
<option value="<?php echo $network?>"><?php echo $network?></option>
<?php }?>
</select>
<br>
<br>
Apply changes to new network: <input type="text" size="50" name="new_network" id="new_network"> (changes will not be applied to any existing networks)
<br>
<br>
<table>
<tr>
<td>
Tag Group 1
<br>
<textarea rows="25" cols="50" name="tags_authentic" id="tags_authentic"></textarea>
</td>
<td>
Tag Group 2
<br>
<textarea rows="25" cols="50" name="tags_ad" id="tags_ad"></textarea>
</td>
<td>
Volley Hashtags (these will get appended into comments)
<br>
<textarea rows="25" cols="50" name="tags_other" id="tags_other"></textarea>
</td>
</tr>
</table>
<br>
<br>
<table>
<tr>
<td>
Quotes Group 1
<br>
<textarea rows="25" cols="50" name="quotes_authentic" id="quotes_authentic"></textarea>
</td>
<td>
Quotes Group 2
<br>
<textarea rows="25" cols="50" name="quotes_ad" id="quotes_ad"></textarea>
</td>
<td>
Quotes Group 3
<br>
<textarea rows="25" cols="50" name="quotes_other" id="quotes_other"></textarea>
</td>
</tr>
</table>
<br>
<br>
<input type="submit" value="submit">
</form>
<script type="text/javascript">
data = <?php echo json_encode($data); ?>;

function populateForm(){
    var network = $("#network").val();
    var fields = ["quotes_authentic","quotes_ad",'quotes_other',"tags_ad","tags_authentic",'tags_other' ];
    for( var n = 0; n < fields.length; n++ ){
        var keys = fields[n].split('_');
        var el = $("#" + fields[n] );
        el.val( data[network][ keys[0] ][ keys[1] ] );
    }
}
populateForm();

</script>
</body>
</html>