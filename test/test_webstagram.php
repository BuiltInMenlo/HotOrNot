<?php
require_once 'vendor/autoload.php';
//$file = '/home/shane/dev/webstagram_valid';
//BIM_Growth_Webstagram_Routines::enablePersonas($file);

$tags = array(
'Canada', 'Canadian', 'Canadiangirls', 'Canadianboys', 'Canadianswag', 'Canucks', 'Ottawa', 'Alberta', 'Edmonton', 'British Columbia', 'Victoria', 'Manitoba', 'Winnipeg', 'Newfoundland', 'Nova Scotia', 'Halifax', 'Ontario', 'Toronto', 'PrinceEdward', 'Quebec', 'Saskatchewan', 'Regina', 'canadaday', 'canadaswonderland', 'canadadry', 'canadagoose', 'canadaproblems', 'canadaday2013', 'canadain', 'canadapost', 'canadasquare', 'canadadaylongweekend', 'canadaday', 'canadaplace', 'canadas', 'canadaflag', 'canadiangirls', 'canadiangirlsdoitbetter', 'canadiangirlskickass', 'canadiangirlsrock', 'canadiangirlswholikegirls', 'makeupcanada', 'stylecanada', 'canadianstyle', 'canadiangirlsknowhowtoparty', 'canadiangirlsarehot', 'canadiangirlswelcome'
);

BIM_Growth_Webstagram_Routines::harvestTags($tags);