<?php

class BIM_Growth_Askfm_Routines extends BIM_Growth_Askfm{
    
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    
    public function __construct( $persona ){
        if( is_string( $persona )  ){
            $persona = new BIM_Growth_Persona( $persona );
        } 
        $this->persona = $persona;
    }
    
    /**
    authenticity_token	7WDGigOVDymawSjk5K5vWa3HVtxtuOIYhntJ1JkDOkk=
    login	exty86@gmail.com
    password	i8ngot6
    follow	
    like	
    back	
    authenticity_token	7WDGigOVDymawSjk5K5vWa3HVtxtuOIYhntJ1JkDOkk= 
    */
    public function login(){
        $url = 'http://www.ask.fm';
        $response = $this->get( $url );
        
        $ptrn = '/name="authenticity_token".*?value="(.+?)"/';
        preg_match($ptrn,$response,$matches);
        
        if( isset( $matches[1] ) ){
            $authToken = $matches[1];
        }
        
        $args = array(
            'login' => $this->persona->askfm->username,
            'password' => $this->persona->askfm->password,
            'authenticity_token' => $authToken,
            'follow' => '',
            'like' => '',
            'back' => ''
        );
        
        $response = $this->post( 'http://ask.fm/session', $args );
        
        return $response;
    }
    
    public function browseQuestions(){
        return $this->askQuestions();
    }
    
    public function askQuestions(){
        $loggedIn = $this->handleLogin();
        if( $loggedIn ){
            $popIds = $this->getPopular();
            
            //print_r( $popIds );exit;
            
            foreach( $popIds as $id ){
                $this->askQuestion( $id );
                $sleep = $this->persona->getBrowseTagsCommentWait();
                echo "submitted comment - sleeping for $sleep seconds\n";
                sleep($sleep);
            }
            $sleep = $this->persona->getBrowseTagsTagWait();
            echo "completed askfm - sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    public function answerQuestions(){
        $loggedIn = $this->handleLogin();
        if( $loggedIn ){
            $questions = $this->getQuestions();
            
            $name = $this->persona->name;
            foreach( $questions as $question ){
                $this->answerQuestion( $question );
                $sleep = $this->persona->getBrowseTagsCommentWait();
                echo "submitted answer for $name - sleeping for $sleep seconds\n";
                sleep($sleep);
            }
            $sleep = $this->persona->getBrowseTagsTagWait();
            echo "completed answering questions for $name - sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    
    /**
_method	put
authenticity_token	QYZClITpvvoMDQNlKJiHYHkAc5Uw4gWVsR0DYPJ0yCM=
question[answer_text]	none
photo_request_id	
commit	Answer
question[submit_stream]	1
question[submit_twitter]	0
question[submit_facebook]	0
     */
    public function answerQuestion( $question ){
        $questionId = $question->id;
        
        $name = $this->persona->askfm->username;
        $url = "http://ask.fm/$name/questions/$questionId/reply";
        $response = $this->get( $url );

        $authToken = '';
        $ptrn = '/name="authenticity_token".*?value="(.+?)"/';
        preg_match($ptrn,$response,$matches);
        if( isset( $matches[1] ) ){
            $authToken = $matches[1];
        }
        
        $answer = $this->persona->getVolleyAnswer( 'askfm' );
        
        $params = array(
            '_method' => 'put',
            'authenticity_token' => $authToken,
            'question[answer_text]'	=> $answer,
            'photo_request_id'	=> '',
            'commit'	=> 'Answer',
            'question[submit_stream]'	=> 1,
            'question[submit_twitter]'	=> 0,
            'question[submit_facebook]'	=> 0
        );
        
        $formActionUrl = "http://ask.fm/questions/$questionId/answer";
        
        $response = $this->post( $formActionUrl, $params, true );
        
        $this->logAnswerSuccess( $questionId, $question->text, $answer, $question->userId, $question->name );
        
        print_r( array( $params ) );
        
    }
    
    public function logAnswerSuccess( $qId, $text, $answer, $userId, $username ){
        $dao = new BIM_DAO_Mysql_Growth_Askfm( BIM_Config::db() );
        $dao->logAnswerSuccess( $qId, $text, $answer, $userId, $username, $this->persona->name );
    }
    
    public function getQuestions(){
        $url = 'http://ask.fm/account/questions';
        $response = $this->get( $url );
        
        // <span class="author nowrap">&nbsp;&nbsp;<a href="/selenagomezsfan" class="link-blue" dir="ltr">Selena Gomez</a></span>
        
        $pattern = '@<div class="questionBox" id="inbox_question_(.*?)">\s*<div class="question" dir="ltr">\s*<span class="text-bold"><span dir="ltr">(.*?)</span>(?:.+?<span class="author nowrap">.*?<a href="(.*?)" class="link-blue" dir="ltr">(.*?)</a></span>)?@is';
        preg_match_all($pattern, $response, $matches);
        
        //print_r( array( $response, $matches ) ); exit;
        
        $questions = array();
        foreach( $matches[1] as $idx => $questionId ){
            $text = '';
            $userId = '';
            $name = '';
            
            if( isset( $matches[2][$idx] ) ){
                $text = $matches[2][$idx];
            }
            if( isset( $matches[3][$idx] ) ){
                $userId = trim( $matches[3][$idx], '/' );
            }
            if( isset( $matches[4][$idx] ) ){
                $name = $matches[4][$idx];
            }
            $questions[] = (object) array(
    			'id' => $questionId,
                'text' => $text,
                'userId' => $userId,
                'name' => $name
            );
        }
        
        $goodQ = array();
        if( $questions ){
            $idsPerTag = $this->persona->idsPerTagInsta();
            
            foreach( $questions as $question ){
                if( count( $goodQ ) < $idsPerTag && $this->canAnswer( $question->id ) ){
                    $goodQ[] = $question;
                }
            }
        }
        return $goodQ;
    }
    
    public function canAnswer( $questionId ){
        return true;
        $canAnswer = false;
        $dao = new BIM_DAO_Mysql_Growth_Askfm( BIM_Config::db() );
        $timeSpan = 86400 * 7;
        $currentTime = time();
        $question = $dao->getQuestion( $questionId );
        if( $question ){
            $canAnswer = true;
        }
        return $canAnswer;
    }
    
    /**
     * 
     * first we check to see if we are logged in
     * if we are not then we login
     * and check once more
     * 
     */
    public function handleLogin(){
        $loggedIn = true;
        $url = 'http://www.ask.fm';
        $response = $this->get( $url );
        if( $this->isNotLoggedIn($response) ){
            $name = $this->persona->name;
            echo "user $name not logged in!  loging in!\n";
            $this->login();
            $response = $this->get( $url );
            if( $this->isNotLoggedIn($response) ){
                $msg = "something is wrong with logging in $name to askfm!  disabling the user!\n";
                echo $msg;
                $this->disablePersona( $msg );
                $loggedIn = false;
            }
        }
        return $loggedIn;
    }
    
    public function getPopular( ){
        $taggedIds = array();
        $idsPerTag = $this->persona->idsPerTagInsta();
        $ids = $this->getPopularIds();
        foreach( $ids as $id ){
            if( count( $taggedIds ) < $idsPerTag && $this->canAsk( $id ) ){
                $taggedIds[] = $id;
            }
        }
        // print_r( $taggedIds ); exit;
        return $taggedIds;
    }
    
    // http://ask.fm/account/popular
        /* <div class="popular-headSet">
    <a href="/Mariiaangeeless" class="border-none"><img alt="" class="popular-pic" src="http://img6.ask.fm/assets/171/805/569/thumb/befunky_instant_156.jpg.jpg"></a>
*/
    public function getPopularIds( $iterations = 1 ){
        $ids = array();
        $pageUrl = "http://ask.fm/account/popular";
        for( $n = 0; $n < $iterations; $n++ ){
            $response = $this->get( $pageUrl );
            $ptrn = '/class="popular-headSet".+?a href="(.+?)".*?class="border-none"/is';
            preg_match_all($ptrn, $response, $matches);
            // print_r( array($response, $matches) ); exit();
            if( isset( $matches[1] ) ){
                array_splice( $ids, count( $ids ),  0, $matches[1] );
            }
            $sleep = $this->persona->getTagIdWaitTime();
            echo "sleeping for $sleep seconds after fetching $pageUrl\n";
            sleep( $sleep );
        }
        $ids = array_unique( $ids );
        $ids = array_map( function( $el ){ return trim( $el, '/ ' ); } , $ids);
        // print_r( array($ids, $tag) );exit;
        return $ids;
    }
    
    public function canAsk( $id ){
        $canPing = false;
        $dao = new BIM_DAO_Mysql_Growth_Askfm( BIM_Config::db() );
        $timeSpan = 86400 * 7;
        $currentTime = time();
        $lastContact = $dao->getLastContact( $id );
        if( ($currentTime - $lastContact) >= $timeSpan ){
            $canPing = true;
        }
        return $canPing;
    }
    
    public function isNotLoggedIn( $html ){
        $ptrn = '@create_account_link@';
        return preg_match($ptrn, $html);
    }
    
    /*
authenticity_token	IHp06ESgZ1Up0Ebiapg83Y4pnebjO4ad7eUBZ8Pwhv8=
question[question_text]	asking myself a question. durrrr. I am so lonely.
question[force_anonymous]	
question[force_anonymous]	force_anonymous
authenticity_token	IHp06ESgZ1Up0Ebiapg83Y4pnebjO4ad7eUBZ8Pwhv8= 

authenticity_token	IHp06ESgZ1Up0Ebiapg83Y4pnebjO4ad7eUBZ8Pwhv8=
question[question_text]	why dont you have a pic yet?
question[force_anonymous]	
authenticity_token	IHp06ESgZ1Up0Ebiapg83Y4pnebjO4ad7eUBZ8Pwhv8=
     */
    
    public function askQuestion( $id ){
        $message = $this->persona->getVolleyQuote();
        $html = $this->get("http://ask.fm/$id");
        
        $ptrn = '/name="authenticity_token".*?value="(.+?)"/';
        preg_match($ptrn,$html,$matches);
        $authToken = '';
        if( isset( $matches[1] ) ){
            $authToken = $matches[1];
        }
        
        $params = array(
            'authenticity_token' => $authToken,
            'question[question_text]' => $message,
            'question[force_anonymous]' => '1',
        );
        
        print_r( $params );
        
        $response = $this->post( "http://ask.fm/$id/questions/create", $params );
        
        if( !preg_match('/your question has been sent/i', $response ) ){
            $this->disablePersona( "disabling ".$this->persona->name." in (class :: function) ".__CLASS__.' :: '.__FUNCTION__ );
            //$this->reLoginWithWait();
        } else {
            $this->logSuccess( $id, $message );
        }
    }
    
    public function reLoginWithWait(){
        $sleep = $this->persona->getLoginWaitTime();
        echo $this->persona->name." no longer logged in! trying login again after sleeping for $sleep seconds\n";
        sleep( $sleep );
        $this->handleLogin();
    }
    
    public function logSuccess( $id, $message ){
        $dao = new BIM_DAO_Mysql_Growth_Askfm( BIM_Config::db() );
        $dao->updateLastContact( $id, time() );
        $dao->logSuccess($id, $message, $this->persona->name );
    }
    
    public function updateUserStats(){
        $this->handleLogin();

        $name = $this->persona->name;
        $profileUrl = "http://ask.fm/$name/";
        $response = $this->get( $profileUrl );

        // @<span class="stasis-digit" id="profile_gifts_counter">0</span>(?:.*?<span class="stasis-digit" id="profile_liked_counter">0</span>)?(?:.*?<span class="stasis-digit" id="profile_answer_counter">5</span>)?@is
        $ptrn = '@<span class="stasis-digit" id="profile_gifts_counter">(.*?)</span>(?:.*?<span class="stasis-digit" id="profile_liked_counter">(.*?)</span>)?(?:.*?<span class="stasis-digit" id="profile_answer_counter">(.*?)</span>)?@is';
        $matches = array();
        preg_match( $ptrn, $response, $matches );
        
        $gifts = isset( $matches[1] ) ? $matches[1] : 0;
        $likes = isset( $matches[2] ) ? $matches[2] : 0;

        $userStats = (object) array(
            'name' => $this->persona->name,
            'gifts' => $gifts,
            'likes' => $likes,
            'network' => 'askfm',
        );

        print_r( $userStats );
        
        $dao = new BIM_DAO_Mysql_Growth_Askfm( BIM_Config::db() );
        $dao->updateUserStats( $userStats );
        
    }
    
}
