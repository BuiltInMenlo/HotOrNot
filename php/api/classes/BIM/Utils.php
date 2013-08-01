<?php 
class BIM_Utils{
    public static function hashMobileNumber( $number ){
        // for now we are not hashing until we decide on a scheme
        return $number;
    }
    
    public static function getSMSCodeForId( $id ){
        $c = BIM_Config::sms();
		$smsCodeB64 = base64_encode( mcrypt_encrypt( MCRYPT_3DES, $c->secret, $id, MCRYPT_MODE_ECB) );
		$smsCode = preg_replace('@^(.*?)(?:=+)$@', '$1', $smsCodeB64);
		$numEqualSigns = mb_strlen( $smsCodeB64 ) - mb_strlen( $smsCode );
		$smsCode = "c1{$smsCode}{$numEqualSigns}1c";
		return $smsCode;
    }
    
    public static function getIdForSMSCode( $smsCode ){
        $c = BIM_Config::sms();
        // first we strip c1 1c
        $ptrn = "@^c1(.*?)1c$@";
        $smsCode = preg_replace( $ptrn, '$1', $smsCode );
        
        // then we look at the last char which is a number
        // that tells us how many equal signs to append
        // to make a proper base64 string
        $idx = mb_strlen( $smsCode ) - 1;
        $numEqualSigns = $smsCode[ $idx ];

        // then we replace the last char
        // and append the equal signs
        $ptrn = "@^(.*?)$numEqualSigns$@";
        $smsCodeB64 = preg_replace( $ptrn, '$1', $smsCode );
        $equalSigns = str_repeat('=', $numEqualSigns);
        $smsCodeB64 .= $equalSigns;
        
        // then decode and decrypt
        $smsCode = base64_decode( $smsCodeB64 );
        $id = mcrypt_decrypt(MCRYPT_3DES, $c->secret, $smsCode, MCRYPT_MODE_ECB);
        
        $id = trim( $id );
        
        return $id;
    }
}