<?php
require_once 'vendor/autoload.php';

$params = (object) array(
	'network' => 'instagram',
	'total_media' => 10,
    'freq' => 10,
    'name' => 'foobar',
);

BIM_Growth::createCampaign($params);