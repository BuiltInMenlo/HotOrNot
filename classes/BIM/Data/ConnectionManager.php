<?php
/**
* This class is a singleton that stores connection handles such as sql db connection handles or cache connection handles.
*/

/**
 * BIM_Data_ConnectionManager_Exception
 */
require_once 'BIM/Data/ConnectionManager/Exception.php';

class BIM_Data_ConnectionManager
{
	
	/**
	 * Singleton instance
	 *
	 * @var BIM_Data_ConnectionManager
	 */
	protected static $instance = null;

	/**
	 * value object that holds the connection refs
	 *
	 * @var BIM_VO
	 */
	protected static $conns = null;

	/**
	 * Singleton pattern implementation makes "new" unavailable
	 *
	 * @return void
	 */
	private function __construct(){ }

	/**
	 * Singleton pattern implementation makes "clone" unavailable
	 *
	 * @return void
	 */
	private function __clone(){ }
	
	/**
	 * set a value under a given name ( key )
	 *
	 * @param mixed $name
	 * @param mixed $value
	 * @throws BIM_Data_ConnectionManager_Exception
	 */
	public static function set( $name, $conn ){
		if(! is_object( $conn ) ){
			throw new BIM_Data_ConnectionManager_Exception("trying to set a connection with something other than an object.");
		}
		if( !self::$conns ){
		    self::$conns = new stdClass();
		}
		self::$conns->$name = $conn;
	}


	/**
	 * gets the value under a given name ( key ) if the key exists
	 *
	 * @param mixed $name
	 * @return mixed
	 */
	public static function get( $name ){
		$conn = null;
		if( isset( self::$conns->$name ) ){
			$conn = self::$conns->$name;
		}
		return $conn;
	}
}
