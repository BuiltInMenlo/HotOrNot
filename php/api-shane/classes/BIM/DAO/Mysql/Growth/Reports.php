<?php

class BIM_DAO_Mysql_Growth_Reports extends BIM_DAO_Mysql_Growth{
	
	public function getSocialStats( $network = '', $persona = '' ){
	    $where = array();
        $params = array();
        
        if( $network ){
            $where[] = ' network = ? ';
            $params[] = 'tumblr';
        }
        
        if( $persona ){
    	  $where[] = ' name = ? ';
    	  $params[] = $persona;
	    }
	    
	    if( $where ){
	        $where = ' where '.join( ' and ', $where );
	    }
	    
		$sql = "
    	  select
              name as persona, 
              network, 
              MONTH( from_unixtime(time) ) as month,      
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              max(followers) as followers,
              max(following) as following,
              max(likes) as likes
          from      
    	      growth.persona_stats_log
    	  $where
          group by name, day
          order by year, month, day
          ";
		$stmt = $this->prepareAndExecute($sql, $params);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $counts;		
	}
    
	public function getSocialStatsForAskfm( $persona = '' ){
	    $where = array();
        $params = array();
        
        if( $persona ){
    	  $where[] = ' name = ? ';
    	  $params[] = $persona;
	    }
	    
	    if( $where ){
	        $where = ' where '.join( ' and ', $where );
	    }
	    
		$sql = "
    	  select
              name as persona, 
              network, 
              MONTH( from_unixtime(time) ) as month,      
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              max(gifts) as gifts,
              max(likes) as likes
          from      
    	      growth.askfm_persona_stats_log
    	  $where
          group by name, day
          order by year, month, day
          ";
		$stmt = $this->prepareAndExecute($sql, $params);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $counts;		
	}
	
	public function getTotalsByPersonaAndNetwork(  $persona = '' ){
	    $where = '';
        $params = array();
	    if( $persona ){
    	  $where = ' where name = ? ';
    	  $params[] = $persona;
    	  $params[] = $persona;
	    }
		$sql = "
    	  select
              name as persona, 
              network, 
              MONTHNAME( from_unixtime(time) ) as month,      
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              count(*) as total     
          from      
    	      growth.contact_log
    	  $where
          group by name, day
    
          union     
          
          select     
              name as persona,     
              network,     
              MONTHNAME( from_unixtime(time) ) as month,
              DAYOFMONTH( from_unixtime(time) ) as day,
              YEAR( from_unixtime(time) ) as year,
              count(*) as total
          from
    	      growth.webstagram_contact_log
    	  $where
          group by name, day;
    
          ";
		$stmt = $this->prepareAndExecute($sql, $params);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
        return $counts;		
	}
	
	public function getOutboundMsgs(){
	    $sql = "set time_zone = '-07:00'";
	    $stmt = $this->prepareAndExecute($sql);
	    
	    $sql = 
	    "select DATE( FROM_UNIXTIME( time ) ) as day , network, count(*) as count
        from growth.contact_log 
        group by day, network
        union
        select DATE( FROM_UNIXTIME( time ) ) as day , network, count(*) as count 
        from growth.webstagram_contact_log 
        group by day, network
        union
        select DATE( FROM_UNIXTIME( time ) ) as day , network, count(*) as count
        from growth.askfm_answer_log
        group by day, network 
        
        order by day desc";

	    $stmt = $this->prepareAndExecute($sql);
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
	
	public function getInboundClicks(){
	    $sql = "set time_zone = '-07:00'";
	    $stmt = $this->prepareAndExecute($sql);
	    
	    $sql = 
        "select DATE( FROM_UNIXTIME( time ) ) as day, network_id as network, count(*) as count
        from growth.inbound_persona_clicks 
        where user_agent not like '%fetchor%'
            and user_agent not like '%googlebot%'
            and user_agent not like '%slurp%'
            and user_agent not like '%tweetmeme%'
            and user_agent not like '%baidu%'
            and user_agent not like '%queryseeker%'
        group by day, network_id order by count(*)";

	    $stmt = $this->prepareAndExecute($sql);
		$counts = $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
		
		$nmap = array(
		    'a' => 'tumblr',
		    'b' => 'webstagram',
			'c' => 'askfm',
			'd' => 'sms',
			'e' => 'email',
		);
		
		foreach( $counts as $row ){
		    foreach( $nmap as $symbol => $network ){
    		    if( $row->network == $symbol ){
    		        $row->network = $network;
    		    }
		    }
		}
		
		return $counts;
	}
	
	public function getPersonaNames(){
	    $sql = "select distinct(name) from growth.persona where enabled != 0";
		$stmt = $this->prepareAndExecute($sql);
		return $stmt->fetchAll( PDO::FETCH_CLASS, 'stdClass' );
	}
}