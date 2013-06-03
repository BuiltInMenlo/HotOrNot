<?php
require_once 'smtp_mailer_swift/lib/swift_required.php';

class BIM_Email_Swift extends BIM_Email{

	protected $transport = null;
	protected $mailer = null;
	
	protected function getMailer(){
		if( !$this->mailer ){
			$transport = $this->getTransport();
			//Create the Mailer using your created Transport
			$this->mailer = Swift_Mailer::newInstance($transport);
		}
		return $this->mailer;
	}

	protected function getTransport(){
		if( !$this->transport ){
			//Create the Transport
			if( isset( $this->config->host ) && isset( $this->config->port ) ){
				$transport = Swift_SmtpTransport::newInstance($this->config->host, $this->config->port);
			} else {
				$transport = Swift_SmtpTransport::newInstance();
			}
				
			if( isset( $this->config->username ) && isset( $this->config->password ) ){
				$transport->setUsername($this->config->username);
				$transport->setPassword($this->config->password);
			}
			$this->transport = $transport;
		}
		return $this->transport;
	}
	
	protected function makeMessage( $email ){
		$message = Swift_Message::newInstance();

		$message->setSubject($email->subject);
		$message->setFrom( array( $email->from_email => $email->from_name ) );
		$message->setTo($email->to_email);

		$text_body = isset(  $email->text  ) ?  $email->text  : '';
		$html_body = isset(  $email->html  ) ?  $email->html  : '';
		if( $text_body ){
			$message->addPart($text_body, 'text/plain');
		}		
		if( $html_body ){
			$message->addPart($html_body, 'text/html');
		}

		return $message;
	}
	
	public function sendEmail( $email ){
		$message = $this->makeMessage($email);		
		$mailer = $this->getMailer();
		$result = $mailer->send($message);
 		
		if (!$result){
			error_log("Message failed to send");
		} 
	}
	
	public function sendQueuedEmail( $qData ){
		$class = $qData->class;
		$conf = require 'config/email.php';
		if( isset( $conf['smtp'] ) ){
		    $conf = $conf['smtp'];
		} else {
		    $conf = null;
		}
		
		$mailer = new $class( $conf );
		return $mailer->sendEmail( $qData->data->email );
	}
	
}
