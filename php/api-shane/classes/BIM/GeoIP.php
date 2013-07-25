<?php 
class BIM_GeoIP {
	public static function OK( $host, $blockList = array() ){
	    $OK = true;
	    if( defined( 'GEOIP_COUNTRY_EDITION' ) && geoip_db_avail( GEOIP_COUNTRY_EDITION ) ){
			$code = geoip_country_code3_by_name( $host );
			if( in_array( $code, $blockList ) ){
			    $OK = false;
			}
	    }
	    return $OK;
	}
}
