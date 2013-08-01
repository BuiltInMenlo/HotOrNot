<?php

class BIM_Email{

	public function __construct( $config = null ){
		$this->config = $config;
	}

	public function emailCronTest( ){
		$emailData = (object) array(
			'to_email' => 'shane@shanehill.com',
			'to_name' => 'Foogery',
			'from_email' => 'shane@nextkite.com',
			'from_name' => 'Boogery',
			'subject' => 'emailCronTest',
			'html' => 'emailCronTest',
		);
		
		$email = (object) array(
			'class' => 'BIM_Email_Swift',
			'method' => 'sendQueuedEmail',
			'data' => (object) array(
				'email' => $emailData,
			),
		);
		
		require_once 'BIM/JobQueue/Gearman.php';
		$q = new BIM_JobQueue_Gearman();
		$q->doBgJob( $email, 'email' );
	}

	public function sendQueuedEmail( $qData ){
		$class = $qData->class;
		$mailer = new $class( );
		return $mailer->sendEmail( $qData->data->email );
	}
}
