<?php
require_once 'vendor/autoload.php';

$r = new BIM_Growth_Reports();
print_r( $r->getReportData() );
