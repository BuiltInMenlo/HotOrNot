<?php

class BIM_DAO_Mysql_Persona extends BIM_DAO_Mysql{
	public function getData( $name = null, $network = null ){
	    
	    $sql = array(); 
	    $params = array();
	    if( $name ){
	        $sql[] = 'name = ?';
		    $params[] = $name;
	    }
	    
	    if( $network ){
	        $sql[] = 'network = ?';
		    $params[] = $network;
	    }
	    
	    $sql = join( ' AND ', $sql );
	    if( $sql ){
	        $sql = "where $sql";
	    }
	    $sql = "select * from growth.persona $sql";
	    
		$stmt = $this->prepareAndExecute( $sql, $params );
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function trackInboundClick( $name, $networkId, $referer = '', $ua = '' ){
	    $sql = "insert into growth.inbound_persona_clicks (name, network_id, referer, time, user_agent) values (?, ?, ?, ?, ?)";
		$params = array( $name, $networkId, $referer, time(), $ua );
		$stmt = $this->prepareAndExecute( $sql, $params );
	}
	
    /*
network , email , username , password , name , extra , enabled , type

instagram|''|Ariannaxoxoluver|teamvolleypassword|Ariannaxoxoluver|{}|1|authentic 
     */
	public function create( $data ){
	    $network = !empty( $data->network ) ? $data->network : '';
	    $email = !empty( $data->email ) ? $data->email : '';
	    $username = $data->username;
	    $password = $data->password;
	    $name = !empty( $data->name ) ? $data->name : $username;
	    $extra = !empty( $data->extra ) ? $data->extra : '';
	    $enabled = !empty( $data->enabled ) ? $data->enabled : '';
	    $type = !empty( $data->type ) ? $data->type : 'authentic';
	    
	    $sql = "
	    	insert ignore into growth.persona
	    	(network , email , username , password , name , extra , enabled , type) 
	    	values ( ?, ?, ?, ?, ?, ?, ?, ? )
	    ";
		$params = array( $network, $email, $username, $password, $name, $extra, $enabled, $type );
		$stmt = $this->prepareAndExecute( $sql, $params );
	}
	
	public function update( $data ){
	    $name = $data->name;
	    unset( $data->name );
	    
	    $network = $data->network;
        unset( $data->network );
        	    
	    $setSql = array();
	    $setParams = array();
        foreach( $data as $prop => $value ){
	        $setSql[] = "$prop = ?";
	        if( $prop == 'extra' ){
	            $value = json_encode( $value );
	        }
	        $setParams[] = $value;
	    }
	    
	    if( $setSql ){
    	    $setParams[] = $name;
    	    $setParams[] = $network;
    	    
    	    $setSql = join(',',$setSql);
            $sql = "
    	    	update growth.persona 
    	    	set $setSql
    	    	where name = ? and network = ?
    	    ";
            
    		$stmt = $this->prepareAndExecute( $sql, $setParams );
	    }
	}
}
