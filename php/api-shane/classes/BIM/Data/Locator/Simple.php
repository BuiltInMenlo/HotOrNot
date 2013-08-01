<?php 

class BIM_Data_Locator_Simple{

	public static function findNode( $id = null, $conf ){
		return $conf->nodes[0];
	}

}

?>