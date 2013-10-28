<?php
require_once 'vendor/autoload.php';
if( $_POST && !empty( $_POST['username'] ) ){
    echo("<pre>");
    print_r(BIM_Model_User::archiveByName( $_POST['username'] ));
    echo("</pre>");
} else {
    echo(
    "
    <html>
    <head>
    </head>
    <body>
    <form method='POST'>
    <input type='submit' value='wipe user'><input type='text' size='50' name='username'>
    </form>
    </body>
    </html>
    "
    );
}

