<?php 
class BIM_Growth_Reports{
    
    protected $report = null;
    
    /*
     * update the 
     * 		totals, 
     * 		totalsByMonth, 
     * 		totalsByDay
     * 
     * 		network totals
     * 		network totals by month
     * 		network total by day
     * 
     * 		persona totals, 
     * 		persona totals By Month, 
     * 		persona totals By Day
     * 
     * 		persona network totals,
     * 		persona network totals By Month, 
     * 		persona network totals By Day
     */
    public function getReportData(){
        $dao = new BIM_DAO_Mysql_Growth_Reports( BIM_Config::db());
        $logs = $dao->getTotalsByPersonaAndNetwork();
        foreach( $logs as $log ){
            $this->updateTotals($log);
            $this->updatePersonaTotals($log);
        }
        //print_r($this->report->personaTotals);
        return( $this->report );
    }
        
    public function updatePersonaTotals( $log ){
        $persona = $log->persona;
        if( !isset( $this->report->personaTotals->$persona ) ){
            $this->report->personaTotals->$persona = new stdClass();
        }
        $totals = $this->report->personaTotals->$persona;
        $this->updateCounts($totals, $log);
    }
    
    public function updateTotals( $log ){
        if( !isset( $this->report->totals ) ){
            $this->report->totals = new stdClass();
        }
        $totals = $this->report->totals;
        $this->updateCounts($totals, $log);
    }
    
    protected function updateCounts( $totals, $log ){
        if( !isset( $totals->total ) ){
            $totals->total = 0;
        }
        $totals->total += $log->total;

        $network = $log->network;
        if( !isset( $totals->byNetwork->$network->total ) ){
            $totals->byNetwork->$network->total = 0;
        }
        $totals->byNetwork->$network->total += $log->total;
        
        $month = "{$log->month} {$log->year}";
        if( !isset( $totals->byMonth->$month->total ) ){
            $totals->byMonth->$month->total = 0;
            $totals->byMonth->$month->byNetwork->$network = 0;
        }
        $totals->byMonth->$month->total += $log->total;
        $totals->byMonth->$month->byNetwork->$network += $log->total;
        
        $day = "{$log->month} {$log->day}, {$log->year}";
        if( !isset( $totals->byDay->$day->total ) ){
            $totals->byDay->$day->total = 0;
            $totals->byDay->$day->byNetwork->$network = 0;
        }
        $totals->byDay->$day->total += $log->total;
        $totals->byDay->$day->byNetwork->$network += $log->total;
    }
}