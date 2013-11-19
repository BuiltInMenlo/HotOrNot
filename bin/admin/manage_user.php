<?php 
require_once 'vendor/autoload.php';
$input = (object) ( $_POST ? $_POST : $_GET );
if( strtolower( $_SERVER['REQUEST_METHOD'] ) == 'get' ){
    //prin the form to search for a user
    echo BIM_App_Admin::getSearchUserForm();
} else if( !empty($input->search)  ) {
    // print the user details
    $input->search = trim($input->search);
    $user = BIM_Model_User::getByUsername($input->search);
    echo BIM_App_Admin::getEditUserForm( $user );
} else if( !empty($input->user)  ){
    $errors = BIM_App_Admin::validateUserData( $input->user );
    if( $errors->ok ){
        $user = BIM_Model_User::get( $input->user['id'] );
        if( !empty($_FILES['avatar']['tmp_name'] ) ){
            BIM_App_Admin::handleUserImage();
            BIM_App_Admin::updateUser( $user, $input->user );
        }
    }
    echo BIM_App_Admin::getEditUserForm( $user, $errors );
}