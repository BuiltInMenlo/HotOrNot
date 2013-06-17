<pre>
<?php
require_once 'vendor/autoload.php';
$r = new BIM_Growth_Reports();
$report = $r->getReportData();
?>
</pre>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-type" content="text/html; charset=utf-8">
		<title>Growth Reports</title>
		
		<link rel="shortcut icon" type="image/ico" href="http://www.datatables.net/media/images/favicon.ico">
		<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
		
		<style type="text/css" media="screen">
			@import "http://www.datatables.net/media/css/site_jui.ccss";
			@import "http://www.datatables.net/release-datatables/media/css/demo_table_jui.css";
			@import "http://www.datatables.net/media/css/jui_themes/smoothness/jquery-ui-1.7.2.custom.css";
			
			/*
			 * Override styles needed due to the mix of three different CSS sources! For proper examples
			 * please see the themes example in the 'Examples' section of this site
			 */
			.dataTables_info { padding-top: 0; }
			.dataTables_paginate { padding-top: 0; }
			.css_right { float: right; }
			#example_wrapper .fg-toolbar { font-size: 0.8em }
			#theme_links span { float: left; padding: 2px 10px; }
			#example_wrapper { -webkit-box-shadow: 2px 2px 6px #666; box-shadow: 2px 2px 6px #666; border-radius: 5px; }
			#example tbody {
				border-left: 1px solid #AAA;
				border-right: 1px solid #AAA;
			}
			#example thead th:first-child { border-left: 1px solid #AAA; }
			#example thead th:last-child { border-right: 1px solid #AAA; }
		</style>
		
		<script type="text/javascript" src="http://www.datatables.net/media/javascript/complete.min.js"></script>
		<script type="text/javascript" src="http://www.datatables.net//release-datatables/media/js/jquery.dataTables.min.js"></script>
		<script type="text/javascript">
			function fnFeaturesInit ()
			{
				/* Not particularly modular this - but does nicely :-) */
				$('ul.limit_length>li').each( function(i) {
					if ( i > 10 ) {
						this.style.display = 'none';
					}
				} );
				
				$('ul.limit_length').append( '<li class="css_link">Show more<\/li>' );
				$('ul.limit_length li.css_link').click( function () {
					$('ul.limit_length li').each( function(i) {
						if ( i > 5 ) {
							this.style.display = 'list-item';
						}
					} );
					$('ul.limit_length li.css_link').css( 'display', 'none' );
				} );
			}
			
			$(document).ready( function() {
				fnFeaturesInit();
				var params =  {
					"bJQueryUI": true,
					"sPaginationType": "full_numbers"
				};
				$('#example').dataTable( params );
				$('#example2').dataTable( params );
				$('#example3').dataTable( params );
				$('#example4').dataTable( params );
				
				SyntaxHighlighter.config.clipboardSwf = 'media/javascript/syntax/clipboard.swf';
				SyntaxHighlighter.all();
			} );
		</script>
		
	</head>
	<body id="index" class="grid_2_3">
		<div id="fw_container">
			
			
<script type="text/javascript">

(function(){
  var bsa = document.createElement('script');
     bsa.type = 'text/javascript';
     bsa.async = true;
     bsa.src = '//s3.buysellads.com/ac/bsa.js';
  (document.getElementsByTagName('head')[0]||document.getElementsByTagName('body')[0]).appendChild(bsa);
})();

</script>
<div id="fw_content">
    <h3>Totals</h3>
    <div class="full_width">
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="example" style="width:980px">
        	<thead>
        		<tr>
        			<th>Total</th>
        			<?php $networks = get_object_vars( $report->totals->byNetwork ); ?>
        			<?php foreach( $networks as $network => $data ) {?>
        			<th style="text-align: center;"><?php echo $network;?></th>
        			<?php }?>
        		</tr>
        	</thead>
        	<tbody>
        		<tr class="gradeA">
        			<td><?php echo $report->totals->total; ?></td>
        			<?php $networks = get_object_vars( $report->totals->byNetwork ); ?>
        			<?php foreach( $networks as $network => $data ) {?>
        			<td class="center"><?php echo $report->totals->byNetwork->$network->total;?></td>
        			<?php }?>
        		</tr>
        	</tbody>
        </table>
    </div>
    
    <br><br>
    <h3>Monthly Totals</h3>
    <div class="full_width">
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="example2" style="width:980px">
        	<thead>
        		<tr>
        			<th>Month</th>
        			<?php $networks = get_object_vars( $report->totals->byNetwork ); ?>
        			<?php foreach( $networks as $network => $data ) {?>
        			<th class="center"><?php echo $network;?></th>
        			<?php }?>
        		</tr>
        	</thead>
        	<tbody>
        		<tr class="gradeA">
        			<?php foreach( $report->totals->byMonth as $month => $monthData ) {?>
            			<td><?php echo $month; ?></td>
            			<?php $networks = get_object_vars( $report->totals->byMonth->$month->byNetwork ); ?>
            			<?php foreach( $networks as $network => $data ) {?>
            			<td class="center"><?php echo $report->totals->byMonth->$month->byNetwork->$network;?></td>
            			<?php }?>
        			<?php }?>
        		</tr>
        	</tbody>
        </table>
    </div>

    <br><br>
    <h3>Daily Totals</h3>
    <div class="full_width">
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="example3" style="width:980px">
        	<thead>
        		<tr>
        			<th>Month</th>
        			<?php $networks = get_object_vars( $report->totals->byNetwork ); ?>
        			<?php foreach( $networks as $network => $data ) {?>
        			<th class="center"><?php echo $network;?></th>
        			<?php }?>
        		</tr>
        	</thead>
        	<tbody>
    			<?php foreach( $report->totals->byDay as $day => $dayData ) {?>
	        		<tr class="gradeA">
            			<td><?php echo $day; ?></td>
            			<?php foreach( $networks as $network => $data ) {
            			    $total = isset( $report->totals->byDay->$day->byNetwork->$network )?$report->totals->byDay->$day->byNetwork->$network:0;
            			?>
            			<td class="center"><?php echo $total;?></td>
            			<?php }?>
	        		</tr>
    			<?php }?>
        	</tbody>
        </table>
    </div>

    <br><br>
    <h3>Persona Totals</h3>
    <div class="full_width">
        <table cellpadding="0" cellspacing="0" border="0" class="display" id="example4" style="width:980px">
        	<thead>
        		<tr>
        			<th>Persona</th>
        			<?php $networks = get_object_vars( $report->totals->byNetwork ); ?>
        			<?php foreach( $networks as $network => $data ) {?>
        			<th class="center"><?php echo $network;?></th>
        			<?php }?>
        		</tr>
        	</thead>
        	<tbody>
    			<?php foreach( $report->personaTotals as $persona => $personaData ) {?>
	        		<tr class="gradeA">
            			<td><?php echo $persona; ?></td>
            			<?php foreach( $networks as $network => $data ) {
            			    $total = isset( $report->personaTotals->$persona->byNetwork->$network->total )
            			        ?  $report->personaTotals->$persona->byNetwork->$network->total
            			        : 0;
            			?>
            			<td class="center"><?php echo $total;?></td>
            			<?php }?>
	        		</tr>
    			<?php }?>
        	</tbody>
        </table>
    </div>

</div>
</body>
</html>