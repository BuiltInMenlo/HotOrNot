<?php 

class BIM_Growth_Persona{
    protected $authenticQuotes = array();
    protected $adQuotes = array();
    
    public function __construct( $params = null ){
        if( is_object($params) ){
            foreach( $params as $prop => $value ){
                $this->$prop = $value;
            }
        } else {
            $this->loadData( $params );
        }
        //$this->adQuotes = BIM_Config::adQuotes('askfm');
        //$this->authenticQuotes = BIM_Config::authenticQuotes('askfm');
    }
    
    public function getTumblrBlogName(){
        $blogName = '';
        if( isset( $this->tumblr->blogName ) ){
            $blogName = $this->tumblr->blogName;
        } else {
            $blogName = $this->tumblr->name.'.tumblr.com';
        }
        return $blogName;
    }
    
    public function getVolleyQuote( $network = '' ){
        if( !empty( $this->type ) && $this->type == 'ad' ){
            $quotes = BIM_Config::adQuotes( $network );
        } else if( !empty( $this->type ) && $this->type == 'authentic'  ){
            $quotes = BIM_Config::authenticQuotes( $network );
        } else{
            $quotes = BIM_Config::otherQuotes( $network );
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        $quote = $quotes[ $idx ];
        $username = explode('@',$this->$network->username);
        $username = $username[0];
        $quote = str_replace('[[USERNAME]]', $username, $quote);
        if( mt_rand(1,100) >= 1 ){
            $quote .= " ".$this->getTrackingUrl( $network );
        }
        return $quote;
    }
    
    /**
     *  // http://taps.io/mta3mty5 - tumblr
     *  // http://taps.io/mta5mdaz - instagram
     *  // http://taps.io/mta5mda3 - askfm
     */
    public function getTrackingUrl( $network ){
        
        $tUrls = array(
            'instagram' => 'http://taps.io/MTA5MDAz',
            'tumblr' => 'http://taps.io/MTA3MTY5',
            'askfm' => 'http://taps.io/MTA5MDA3',
        );
        
        $url = '';
        if( !empty( $tUrls[ $network ] ) ){
            $url = $tUrls[ $network ];
        }
        
        /*
        if( !$network ){
            $network = 'instagram';
        }
        $networkSymbol = 'b';
        
        if( $network == 'tumblr' ){
            $networkSymbol = 'a';
        } else if( $network == 'askfm' ){
            $networkSymbol = 'c';
        }
        $name = explode('@',$this->name);
        $name = $name[0];
        $url = "http://getvolleyapp.com/$networkSymbol/$name";
        */
        
        return $url;
    }
    
    public function getVolleyAnswer( $network = '' ){
        if( !empty( $this->type ) && $this->type == 'ad' ){
            $quotes = BIM_Config::adTags( $network );
        } else if( !empty( $this->type ) && $this->type == 'authentic' ){
            $quotes = BIM_Config::authenticTags( $network );
        } else {
            $quotes = BIM_Config::otherTags( $network );
        }
        
        $ct = count( $quotes ) - 1;
        $idx = mt_rand(0, $ct);
        $quote = $quotes[ $idx ];
        if( mt_rand(1,100) >= 1 ){
            $quote .= " ".$this->getTrackingUrl( $network );
        }
        return $quote;
    }
    
    protected function loadData( $name ){
        $this->dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $data = $this->dao->getData( $name );
        if( $data ){
            $type = 'authentic';
            foreach( $data as $row ){
                if( isset( $row->type ) ){
                    $type = $row->type;
                }
                $network = $row->network;
                $this->$network = $row;
                if( $row->extra ){
                    $extra = json_decode( $row->extra );
                    if( $extra ){
                        foreach( $extra as $prop => $value ){
                            $this->$network->$prop = $value;
                        }
                    }
                }
                unset( $row->type );
                unset( $row->network );
                unset( $row->extra );
            }
            $this->name = $name;
            $this->type = array_rand( array('ad','authentic','other') );
        }
    }
    
    public function getTags( $network = '' ){
        if( !empty( $this->type ) && $this->type == 'ad' ){
            $tags = BIM_Config::adTags( $network );
        } else if( !empty( $this->type ) && $this->type == 'authentic' ){
            $tags = BIM_Config::authenticTags( $network );
        } else {
            $tags = BIM_Config::otherTags(  $network );
        }
        return $tags;
    }
    
    public function numTagsToRetrieveInsta( ){
        return 1;
    }
    
    public function getLoginWaitTime( ){
        return mt_rand(180, 300);
    }
    
    public function getTagIdWaitTime( ){
        return mt_rand(4, 6);
    }
    
    public function getBrowseTagsCommentWait( ){
        return mt_rand(15, 30);
    }
    
    public function numQuestionsToGet( ){
        return mt_rand(1, 10);
    }
    
    public function getBrowseTagsTagWait( ){
        return mt_rand(1, 10);
    }
    
    // idsPerTagInsta
    public function idsPerTagInsta( ){
        return 5;
    }
    
    public function trackInboundClick( $networkId, $referer = '', $ua = '' ){
        $dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $dao->trackInboundClick($this->name, $networkId, $referer, $ua );
        return true;
    }
    
    public function isExtant(){
        return isset( $this->name ) && $this->name;
    }
    
    public function getAskfmSearchName(){
        // $names = explode(',',"canada,canadaday,canadagoose,canadaswonderland,canadadry,canadaplace,canadaeh,canadadayweekend,canadas,canadabound,canadaday2013,canadaproblems,canadaflag,canadalife,canadageese,canadatrip,canada2013,canadagram,canadapost,canadasday,canadagotsole,canada2012,canadadaylongweekend,canadain,canadaslondon,canadaprobs,canada_goods,canadasucks,canadarocks,canadawater,canadaswag,canadaphoto,canadair,canadaline,canadalove,canadapride,canadaday2012,canadawonderland,canadafirstnations,canadiangirl,canada,canadaday,canadagoose,canadaswonderland,canadadry,canadaplace,canadaeh,canadadayweekend,canadas,canadabound,canadaday2013,canadaproblems,canadaflag,canadalife,canadageese,canadatrip,canada2013,canadagram,canadapost,canadasday,canadagotsole,canada2012,canadadaylongweekend,canadain,canadaslondon,canadaprobs,canada_goods,canadasucks,canadarocks,canadawater,canadaswag,canadaphoto,canadair,canadaline,canadalove,canadapride,canadaday2012,canadawonderland,canadafirstnations,canadavsusa,canadaweather,canadaboy,canadacup,canadapics,canadaig,canadaolympicpark,canadahereicome,canadarules,canadapooch,canadasquare,canadian,canadianstoners,canadians,canadiangirl,canadianproblems,canadianstoner,canadiangirls,canadianboy,canadianchron,canadianclub,canadianchivers,canadiantire,canadianrockies,canadianwinter,canadianphotography,canadiantuxedo,canadianbacon,canadiangeese,canadianpride,canadianflag,canadiankush,canadianprobs,canadianlife,canadianforces,canadianweather,canadianeh,canadianswag,canadiangoose,canadianmoney,canadiana,canadianwinters,canadianbeer,canadianbud,canadianhighgrade,canadianboys,canadiantrees,canadianmusic,canadiancancersociety,canadianthanksgiving,canadianmade,canadiansinger,canadianchronic,canadiandogs,canadiangp,canadiangeographic,canadianart,canadianfashion,canadianclassics,canadianpizza,canadianlesbian,vancouver,vancouverisland,vancouverbc,vancouvercanucks,vancouverisawesome,vancouveraquarium,vancouverlife,vancouverwa,vancouvergrizzlies,vancouverfashion,vancouver2010,vancouver_bc,vancouverartgallery,vancouverliving,vancouverbound,vancouvergiants,vancouverwashington,vancouverfashionweek,vancouverweather,vancouverfood,vancouvercity,vancouverite,vancouverstyle,vancouversunrun,vancouvergirl,vancouverwhitecaps,vancouverdowntown,vancouvertattoo,vancouverpop,vancouverlove,vancouverairport,vancouver2013,vancouverart,vancouverarchitecture,vancouverpride,vancouvercanada,vancouvercanadians,vancouvereats,vancouversucks,vancouverconventioncentre,vancouver2012,vancouversun,vancouverphotographer,vancouverclub,vancouverhair,vancouverigers,vancouverproblems,vancouverautos,vancouverchristmasmarket,vancouverzoo,montreal,montrealcanadiens,montrealcity,montrealgraffiti,montrealer,montrealcanadians,montrealcars,montrealpics,montrealphoto,montrealphotography,montrealnightlife,montrealstreetart,montrealfood,montrealracing,montrealgazette,montreal2013,montrealfashion,montrealimpact,montrealproblems,montrealin,montrealenlumiere,montrealview,montrealart,montreallife,montrealexpos,montreality,montrealbound,montrealdogs,montrealigers,montrealbud,montrealcanada,montrealdowntown,montrealevents,montrealtattoo,montrealautos,montrealmetro,montrealfashionweek,montrealgraffitiart,montrealers,montrealjazzfest,montreal2012,montrealjazzfestival,montreallove,montrealsmokedmeat,montrealweather,montrealgirl,montrealbynight,montrealtrip,montrealcomiccon,montrealcakes,edmonton,edmontonhumanesociety,edmontonoilers,edmontonspca,edmontoneskimos,edmontonbound,edmontonalberta,edmontonproblems,edmontonphotography,edmontonweather,edmontonmall,edmontonexpo,edmontonrush,edmontonlife,edmontontattoo,edmontonhumane,edmontontransit,edmontonsucks,edmontonian,edmontonab,edmontonjournal,edmontonvalleyzoo,edmontonoilkings,edmontontourism,edmontonzoo,edmontontrip,edmontonpride,edmontonhotties,edmontonindy,edmontonchivers,edmontonstoners,edmontonrivervalley,edmontonsun,edmontontattoos,edmontonmotorshow,edmontongirls,edmontonairport,edmontonart,edmonton2013,edmontonphoto,edmontoncar,edmontonfolkfest,edmontoniloveyou,edmontonimpact,edmontonians,edmontoninternationalairport,edmontongay,edmontonprobs,edmontongreen,edmontonerrl,loonie,canuck,canucks,canucksnation,canuckssuck,canucksgame,canuckstagram,canucksfan,canuckleheads,canucknation,canucksjersey,canucksfans,canuckfan,canuckshockey,canuckpride,canucklehead,canuckspride,canucksgirl,canucksforthecup,canuckshat,canucksrule,canuckplace,canuckswin,canuckslove,canucksshirt,canucksautismnetwork,canucksforlife,canuckstuff,canucksincali,canuckswon,canuckfans,canucksbaby,canucklove,canucklife,canucksswag,canucksplayoffs,canuckscat,canucksuck,canucksvssharks,canucksupdate,canuckifyoubucktour,canucksvsflames,canucktourlife,canuckgame,canuckslost,canuckssucks,canuckswag,canucksrock,canucks2013,canuckssuperskills,canucksriot,toronto,torontomapleleafs,torontolife,torontozoo,torontophotography,torontobluejays,torontoraptors,torontograffiti,torontoisland,torontoigers,torontopride,torontodogs,torontoshottest,torontofashion,torontofood,torontolove,torontonightlife,torontobound,torontofc,torontostreetart,torontotattoo,torontofashionweek,torontoart,torontogay,torontoskyline,torontogirl,torontoeats,torontoartist,torontoislands,torontoproblems,torontoliving,torontograffitiart,torontoflood,torontotattoos,torontocity,torontorock,torontostar,torontoautoshow,torontocanada,torontophotos,torontomusic,torontoweather,torontonights,torontoevents,torontophotographer,torontostyle,torontobarbers,torontorealestate,torontomarlies,toronto2013,canadaday,canadadayweekend,canadaday2013,canadadaylongweekend,canadaday2012,canadadaylondon,canadadayfireworks,canadadayparade,canadadays,canadadaystreetteam,canadadayfun,canadadaycelebrations,canadadayparty,canadadaycap,canadadaybaby,canadadaynails,canadadaycelebration,canadadaynyc,canadadayeh,canadadaylong,canadaday2011,canadadaywknd,canadadayeve,canadadayswag,ontario,ontariomills,ontarioreign,ontarioplace,ontariocanada,ontariolake,ontarioparks,ontarioca,ontarioimprov,ontariosciencecentre,ontariobound,ontarioairport,ontariodogs,ontariomillsmall,ontariocalifornia,ontariowithlove,ontariograffiti,ontariosciencecenter,ontariocraftbeer,ontariocup,ontarios,ontariohighschool,ontariochampionships,ontariophysique,ontariosummergames,ontariohigh,ontariomall,ontariooregon,ontarioconsumers,ontarioscholar,ontariolesbian,ontariolivin,ontarioconventioncenter,ontariolife,ontarioknives,ontariostreet,ontariorugby,ontarionorthland,ontariosbby,ontariobasketball,ontariocobaltclub,ontariostrawberries,ontariowine,ontarioiguanas,ontariophotography,ontariofishing,ontariobeach,ontarioreignhockey,ontarioreigns,ontariogrown,quebec,quebeccity,quebecois,quebecoise,quebec2013,quebectrip,quebecpass,quebecgirl,quebecmagnetic,quebec2012,quebecity,quebecer,quebecstoners,quebecoriginal,quebecnordiques,quebecbaddest,quebecregion,quebeccanada,quebecproblems,quebecopen,quebec_city,quebecdog,quebecbeer,quebecers,quebecbound,quebeccrownvic,quebeclibre,quebeccity2013,quebeclife,quebecgold,novascotia,novascotiaducktollingretriever,novascotiaducktollingretriver,novascotian,novascotiaducktoller,novascotiaducktolling,novascotiannoutaja,novascotianducktollingretriever,novascotiaducktollingretreiver,novascotiaretriever,novascotiatourism,novascotia2013,novascotiavacation,novascotiabound,novascotiaweather,novascotiaducktollers,novascotiaducktollingretrievers,novascotians,novascotiacanada,novascotianretriever,novascotiasights,novascotialobster,novascotialiving,novascotiapride,novascotiaproblems,novascotiabeaches,novascotiagirl,novascotiatrip,novascotiabeauty,novascotiaprobs,novascotianducktoller,novascotia_igers,novascotiaducktollingreteriver,novascotialife,novascotiamuseums,novascotialove,novascotiafishing,novascotiawine,novascotiapower,novascotiaflag,novascotiaducktollenretriever,novascotiawinter,novascotiaducktollerretriever,novascotiaducktollerretriver,novascotiawines,novascotiasummer,novascotiatattoo,novascotiabarber,novascotiaducktrollingretriever,novascotiaphotographer,manitoba,manitobaphotography,manitobamarathon,manitobamuseum,manitobahmukluks,manitobah,manitobaharvest,manitobas,manitobaproblems,manitobamutts,manitoban,manitobaweather,manitobahydro,manitobabound,manitobawinter,manitobamoose,manitobamusic,manitobatourism,manitobamukluks,manitobagames,manitobawinters,manitobadancefestival,manitobaunderdogs,manitobaclub,manitobalegislativebuilding,manitobamutt,manitobamarathon2013,manitobasummer,manitobagirl,manitobalife,manitobans,manitobaprobs,manitobakiting,manitobagermanshepherdrescue,manitobaparks,manitobaskies,manitobafishing,manitobamarlins,manitobacream,manitobastart,manitobamagic,manitobasky,manitobasocial,manitobastormcheer,manitobasucks,manitobalove,manitobasummers,manitobamuttsdogrescue,manitobalegislature,manitobaspring,alberta,albertabound,albertaferretti,albertacos,albertan,albertalife,albertasky,albertaweather,albertaskies,albertaproblems,albertaflood,albertagirl,albertastreet,albertabest,albertabeef,albertabeach,albertaoil,albertafloods,alberta3,albertacross,albertastrong,albertawinter,albertacanada,albertacheerempire,albertaballet,albertaflood2013,albertapremium,albertaboy,albertas,albertaprobs,albertasummergames,albertans,albertagirls,albertasucks,albertaferreti,albertadria,albertasunset,albertalove,albertaliving,albertapure,albertarockies,albertaart,albertast,albertaspring,albertapride,albertafalls,albertafloods2013,albertaferetti,albertaevolution,albertachildrenshospital,britishcolumbia,britishcolumbiacanada,britishcolumbiaua,britishcolumbian,britishcolumbians,britishcolumbiaweather,britishcolumbianwolf,britishcolumbiabound,britishcolumbiamma,britishcolumbiaartist,britishcolumbiarailway,britishcolumbianskies,britishcolumbiaisbeautiful,britishcolumbiabud,britishcolumbiaisawesome,britishcolumbiawolf,britishcolumbiatattoos,britishcolumbiaskasociety,britishcolumbiasbest,britishcolumbiapenitentiary,britishcolumbiaproblems,britishcolumbiaoysters,britishcolumbia2013,britishcolumbiankush,britishcolumbiacapitol,britishcolumbialuvv,britishcolumbiainstituteoftechnology,britishcolumbialegislaturebuilding,britishcolumbiaflag,britishcolumbiasfinest,britishcolumbiatrip,britishcolumbiaparliamentbuilding,britishcolumbiavisit,britishcolumbiaparliament,britishcolumbiadreaming,britishcolumbia2011,britishcolumbiamulies,britishcolumbiamountains,britishcolumbianredapples,britishcolumbiacheese,britishcolumbialove,britishcolumbialovin,britishcolumbiambulanceservice,britishcolumbialions,britishcolumbiababy,britishcolumbiahereicome,britishcolumbiagirl,britishcolumbiagirlistakingoveralberta,britishcolumbiadunrise,britishcolumbiagolf,halifax,halifaxmooseheads,halifaxharbour,halifaxriver,halifaxns,halifaxuk,halifaxfashion,halifaxwaterfront,halifaxshopping,halifaxbound,halifaxpride,halifaxairport,halifaxgrammar,halifaxpublicgardens,halifaxnovascotia,halifaxmetrocentre,halifaxpopexplosion,halifaxcommons,halifaxshoppingcentre,halifaxcheerelite,halifaxshoppingcenter,halifaxart,eh,canadiens,canadiense,canadiensdemontreal,canadienses,canadiensmtl,canadiensmontreal,canadienssuck,,canadiensdemtl,canadienstoner,canadiensofmontreal,canadienstoners,canadienshockey,canadiensfan,canadiensgame,canadienswag,canadienstyle,canadiensvsbruins,canadiensrule,canadiensnation,canadiensdumontreal,canadiensa,canadiensjersey,canadiensas,canadienside,canadienshat,canadiensblow,canadiensvsflyers,canadiensarepussies,canadiensarehot,canadiensgirls,canadiensstink,canadiensshirt,canadiensvssenators,canadiensvspanthers,canadiensfans,canadiensvsdevils,canadienseh,canadienskateboarding,canadiensgrandprix2013,canadiensuck,canadienshalloffame,canadienslose,canadiensvscapitals,canadiensforever,canadienssenators,canadiensrock,canadiensareweird,canadiensen6,canadiensforthewin,degrassi,degrassishowdown,degrassiseason12,degrassian,degrassithenextgeneration,degrassicast,degrassians,degrassitng,degrassimoment,degrassiseason13,degrassiseason10,degrassifriday,degrassiseason11,degrassijuniorhigh,degrassiphotochallenge,degrassichallenge,degrassihigh,degrassirp,degrassiroleplay,degrassiphotoadaychallenge,degrassiisthebest,degrassi7daychallenge,degrassilasvegas,degrassigoestoghana,degrassipremiere,degrassifan,degrassilove,degrassidays,degrassiboys,degrassigirls,degrassipromo,degrassifeels,degrassiprobs,degrassifangirlproblems,degrassinextgeneration,degrassilife,degrassiisback,degrassimarchchallenge,fazemagazine,fazemagazineevent,muchmusic,muchmusicvideoawards,muchmusicawards,muchmusicvjsearch,muchmusicvj,muchmusicdance,muchmusicvideodance,muchmusiccountdown,muchmusiclive,muchmusiccovers,muchmusicaward,muchmusicvideoawards2013,muchmusicvj2013,muchmusicvideoaward,muchmusicvideo,muchmusicvjsearch2013,muchmusicdanceparty,muchmusicawards2013,muchmusiccanada,muchmusiccocacolacovers,muchmusictv,muchmusicmemories,muchmusicbuilding,muchmusichq,muchmusicvideoawards2012,muchmusicmovieawards,muchmusicisjexy,muchmusichost,muchmusicawards2012,muchmusiccovers2013,muchmusicbigjingle,muchmusiccoverscontest,muchmusicinterview,muchmusicvideodanceparty,muchmusic2013,muchmusicholidaywrap,muchmusicpromo,muchmusicvjs,muchmusicvideoswards,muchmusicpresents,muchmusicmukesh,muchmusicawarsd,muchmusicvideoawars,muchmusicdance2013,muchmusicprom,muchmusicmmvas,muchmusicawardsrehersal,muchmusicla,muchmusicvideoawards2011,muchmusicinternstyle,fuze,canadiana,canadianart,canadianarmy,canadianartist,canadianangel,canadianacool,canadianandproud,canadianarmedforces,canadianadventure,canadianartists,canadianatheart,canadianairsoft,canadianautoshow,canadianabroad,canadianadventures,canadianairforce,canadianaccent,canadianactor,canadianactress,canadianadventure2013,canadianamerican,canadianautoshow2013,canadianacademy,canadianauthor,canadianapparel,canadianairlines,canadiananthem,canadianarchitecture,canadianathletes,canadianaccents,canadianautumn,canadianapartment,canadianaussie,canadianauthors,canadianaye,canadiananimalassistanceteam,canadianair,canadianalltheway,canadianactivities,canadianaffair,canadianarctic,canadianathlete,canadianaddictions,canadianas,canadianangle,canadianaviationmuseum,canadianadventurecamp,canadianale,canadiananimals,fusetv,fusechannel,canadianschool,canadianschoolgdl,canadianschooloflutherie,canadianschoolofdance,canadianschoolofballet,canadianschools,canadianschoolbus,canadianschoolsystem,canadianschoolteam,canadianschoolofnaturalnutrition,canadianschoolofvolleyball,canadianschoolofwarsaw,canadianschoolphoto,canadianschoolproblems,canadianschoolprobs,canadianschoolseh,canadianschoolstaff,canadianschoolteacher,canadianschoolway,canadianschoolainfal,canadianschoolboardswagg,canadianschoolboys,canadianschoolfamily,canadianschoolfestival,canadianschoolisajoke,canadianschoolmaths,canadianschoolofnationalnutrition,canadiangirls,canadiangirlsdoitbetter,canadiangirlskickass,canadiangirlsrock,canadiangirlswholikegirls,canadiangirlsofig,canadiangirlsdoitbest,canadiangirlsofinstagram,canadiangirlskikass,canadiangirlswag,canadiangirlsthatlikegirls,canadiangirlsdoitright,canadiangirlsrule,canadiangirlswhosmokeweed,canadiangirlsarethebest,canadiangirlsknowhowtoparty,canadiangirlssmokekush,canadiangirlswelcome,canadiangirlstopmotionshowtodefrizzdollhair,canadiangirlsdrinkingteam,canadiangirlslovehim,canadiangirlssmokeweed,canadiangirlshavemorefun,canadiangirlssmokepot,canadiangirlsarehot,canadiangirlsarebetter,canadiangirlstoners,canadiangirlsarebest,canadiangirlsdousa,canadiangirlswaggcontest,canadiangirlstopmotiontutorials,canadiangirlsgonewild,canadiangirlseh,canadiangirlsarethehottest,canadiangirlsolutions,canadiangirlslovehockey,canadiangirlstopmotionps,canadiangirlstastelikemaplesyrupandbaconnigga,canadiangirlsarecool,canadiangirlsbelike,canadiangirlsinla,canadiangirlss,canadiangirlsarebeautiful,canadiangirlssss,canadiangirlsrthe,canadiangirlsrockthecheekylook,canadiangirlsdoitbettter,canadiangirlsdoigright,canadiangirlslovefacepaint,canadiangirlslovecountry,hoser,hosers,hosereel,hosery,hoserphotography,hoserhut,hoseriding,hoserpalazuelos,hoseriproblemi,hoserika,hoserlife,hoseroll,hoserunter,hoserhat,hosercomposer,hoserack,hoserburlesque,hosersbachelorweekend,hosernation,hoserparty,hosers4life,hosermachine,hoseriousfun,hoserainbow,hoserfest,hosereels,hosernstinge,hosersinparadise,hosers8,hoserandjoell,hoseraces,hoserie,hoseradish,hoseries,hoseracing,hoserace,hoserhouse,hoserandsavannah,hoserutscht,hoserpride,hoserain,hoser4life,hoserpower,hoserepair,hosernwk,hosermachine2,hoserolls,hoserik,hosering,hoserone,maplesyrup,maplesyrupstagram,maplesyrupfestival,maplesyrupdiet,maplesyrupfest,maplesyrupbacon,maplesyrupsunday,maplesyrupstagramfam,maplesyrupcandy,maplesyrupseason,maplesyrupsausage,maplesyrupmaking,maplesyruptime,maplesyruptakeover,maplesyrupfrosting,maplesyrupfeelings,maplesyrupfarm,maplesyrupinstagram,maplesyruponeverything,maplesyrupshots,maplesyrupvodka,maplesyrupandbacon,maplesyruppancakes,maplesyrupconglomerate,pink,art,hot,instahub,photo,throwbackthursday,statigram,cat,my,family,clouds,amazing,awesome,girls,textgram,jj_forum,all_shots,baby,music,red,repost,black,instalove,igaddict,party,yummy,instago,night,green,white,bestfriend,yum,ignation,followback,harrystyles,eyes,school,foodporn,2012,sweet,style,water,niallhoran,boy,nails,yolo,nice,beauty,i,flower,zaynmalik,best,louistomlinson,liampayne,instacollage,blonde,bestfriends,1d,puppy,flowers,work,instacool,makeup,shoes,insta,adorable,birthday,friend,10likes,likeforlike,gang_family,boyfriend,good,nyc,morning,you,instapic,the,sea,blackandwhite,haha,instaphoto,jusgramm,day,tree,dinner,crazy,20likes,shoutout,throwback,home,gorgeous,true,truth,justinbieber,bieber,mtv,yolo,swag,sister,instaplace,igsg,homework,flashbackfriday,british,warm,skyline,phone,hiphop,styles,tweetgram,jeep,watch,brooklyn,russia,februarychallenge,japanese,instamillion,instanature,son,storm,draw,single,tagstagramers,drake,2011,skate,classy,pop,macro,hungergames,hk,harrypotter,bar,jesus,fotorus,instagramtagsdotcom,waiting,diy,outdoors,directioners,mcdonalds,djmalik,missyou,hehe,child,movies,what,awesome_shots,love,instagood,me,cute,tbt,photooftheday,instamood,tweegram,iphonesia,picoftheday,igers,summer,girl,instadaily,beautiful,instagramhub,iphoneonly,igdaily,bestoftheday,follow,webstagram,picstitch,jj,happy,sky,nofilter,fashion,followme,fun,sun,smile,instagramers,food,pretty,friends,nature,onedirection,hair,beach,lol,like,swag,dog,funny,blue,life,bored,cool,sunset,versagram,instagoodme,cute,tbt,photooftheday,instamood,tweegram,iphonesia,picoftheday,igers,summer,girl,instadaily,beautiful,instagramhub,iphoneonly,igdaily,bestoftheday,follow,webstagram,picstitch,jj,happy,sky,nofilter,fashion,followme,fun,sun,smile,instagramers,food,pretty,friends,nature,onedirection,hair,beach,lol,like,swag,dog,funny,blue,life,bored,cool,sunset,versagram,coffee,to,quote,forever,nike,drawing,pet,drunk,gf_daily,travel,bff,follow4follow,brother,f4f,clubsocial,so,view,kiss,a,instagrammer,goodtimes,starbucks,landscape,today,vacation,street,cutie,football,brown,gay,tagsforlikes,swedish,sisters,icecream,cats,pic,holiday,sunny,live,tan,pool,shopping,italy,with,architecture,myself,sad,it,japan,lake,best,louistomlinson,liampayne,instacollage,blonde,bestfriends,1d,puppy,flowers,work,instacool,makeup,shoes,insta,adorable,birthday,friend,10likes,likeforlike,gang_family,boyfriend,good,nyc,morning,you,instapic,the,sea,new,blackandwhite,haha,instaphoto,jusgramm,day,tree,dinner,crazy,20likes,like4like,shoutout,trees,sister,throwback,tattoo,and,tired,home,gorgeous,true,canada,happybirthday,relaxing,nephew,ink");
        $names = array(
            "AlingsŒs',
            'Arboga",
            "Arvika",
            "Askersund",
            "Avesta",
            "Boden",
            "BollnŠs",
            "Borgholm",
            "BorlŠnge",
            "BorŒs",
            "Djursholm",
            "Eksjš",
            "Enkšping",
            "Eskilstuna",
            "Eslšv",
            "Fagersta",
            "Falkenberg",
            "Falkšping",
            "Falsterbo[1]",
            "Falun",
            "Filipstad",
            "Flen",
            "Gothenburg",
            "GrŠnna",
            "GŠvle",
            "Hagfors",
            "Halmstad",
            "Haparanda",
            "Hedemora",
            "Helsingborg",
            "Hjo",
            "Hudiksvall",
            "Huskvarna",
            "HŠrnšsand",
            "HŠssleholm",
            "HšganŠs",
            "Jšnkšping",
            "Kalmar",
            "Karlshamn",
            "Karlskoga",
            "Karlskrona",
            "Karlstad",
            "Katrineholm",
            "Kiruna",
            "Kramfors",
            "Kristianstad",
            "Kristinehamn",
            "Kumla",
            "Kungsbacka",
            "KungŠlv",
            "Kšping",
            "Laholm",
            "Landskrona",
            "Lidingš",
            "Lidkšping",
            "Lindesberg",
            "Linkšping",
            "Ljungby",
            "Ludvika",
            "LuleŒ",
            "Lund",
            "Lycksele",
            "Lysekil",
            "Malmš",
            "Mariefred",
            "Mariestad",
            "Marstrand",
            "Mjšlby",
            "Motala",
            "Nacka",
            "Nora",
            "Norrkšping",
            "NorrtŠlje",
            "Nybro",
            "Nykšping",
            "NynŠshamn",
            "NŠssjš",
            "Oskarshamn",
            "Oxelšsund",
            "PiteŒ",
            "Ronneby",
            "Sala",
            "Sandviken",
            "Sigtuna",
            "Simrishamn",
            "Skanšr med Falsterbo[3]",
            "Skanšr[4]",
            "Skara",
            "SkellefteŒ",
            "SkŠnninge",
            "Skšvde",
            "SollefteŒ",
            "Solna",
            "Stockholm",
            "StrŠngnŠs",
            "Stršmstad",
            "Sundbyberg",
            "Sundsvall",
            "SŠffle",
            "SŠter",
            "SŠvsjš",
            "Sšderhamn",
            "Sšderkšping",
            "SšdertŠlje",
            "Sšlvesborg",
            "Tidaholm",
            "TorshŠlla",
            "TranŒs",
            "Trelleborg",
            "TrollhŠttan",
            "Trosa",
            "Uddevalla",
            "Ulricehamn",
            "UmeŒ",
            "Uppsala",
            "Vadstena",
            "Varberg",
            "Vaxholm",
            "Vetlanda",
            "Vimmerby",
            "Visby",
            "VŠnersborg",
            "VŠrnamo",
            "VŠstervik",
            "VŠsterŒs",
            "VŠxjš",
            "Ystad",
            "mŒl",
            "€ngelholm",
            "…rebro",
            "…regrund",
            "…rnskšldsvik",
            "…stersund",
            "…sthammar",
        );
        
        if( $this->type == 'ad' ){
            $names = array(
                'Arendal',
                'Bergen',
                'Bod¿',
                'Drammen',
                'Egersund',
                'Farsund',
                'Flekkefjord',
                'Flor¿',
                'Fredrikstad',
                'Gj¿vik',
                'Grimstad',
                'Halden',
                'Hamar',
                'Hammerfest',
                'Harstad',
                'Haugesund',
                'Holmestrand',
                'Horten',
                'H¿nefoss',
                'Kongsberg',
                'Kongsvinger',
                'Kristiansand',
                'Kristiansund',
                'Larvik',
                'Lillehammer',
                'Mandal',
                'Molde',
                'Moss',
                'Namsos',
                'Narvik',
                'Notodden',
                'Oslo',
                'Porsgrunn',
                'Ris¿r',
                'Sandefjord',
                'Sandnes',
                'Sarpsborg',
                'Skien',
                'Stavanger',
                'Steinkjer',
                'Troms¿',
                'Trondheim',
                'T¿nsberg',
                'Vads¿',
                'Vard¿',
                'lesund',
            );
        } else if( $this->type == 'authentic' ){
        
            $names = array(
                "100 Mile House",
                "Abbotsford",
                "Airdrie",
                "Ajax canada",
                "Alberton canada",
                "Aldergrove",
                "Alert Bay",
                "Algonquin Park",
                "Alma canada",
                "Amherst canada",
                "Amherstburg",
                "Ancienne Lorette",
                "Anjou canada",
                "Annapolis Royal",
                "Antigonish",
                "Arnprior",
                "Athabasca",
                "Aurora",
                "Baddeck",
                "Baie Comeau",
                "Baie-Saint-Paul",
                "Bancroft",
                "Banff",
                "Barrie",
                "Bathurst",
                "Bayside",
                "Beauport",
                "Beaupre",
                "Beausejour",
                "Becancour",
                "Bedeque",
                "Belleville",
                "Berthierville",
                "Blainville",
                "Blandford",
                "Boucherville",
                "Bouctouche",
                "Boutiliers Point",
                "Bowmanville",
                "Bracebridge",
                "Bragg Creek",
                "Brampton",
                "Brandon",
                "Brantford",
                "Bridgewater",
                "Brockville",
                "Brooks",
                "Brossard",
                "Burlington",
                "Burnaby",
                "Burntcoat",
                "Cache Creek",
                "Calgary",
                "Cambridge",
                "Campbell River",
                "Campbellton",
                "Canmore",
                "Cape Breton",
                "Caraquet",
                "Carbonear",
                "Cardigan",
                "Castlegar",
                "Cavendish",
                "Charlottetown",
                "Chase",
                "Chatham",
                "ChŽticamp",
                "Chevery",
                "Chicoutimi",
                "Chilliwack",
                "Churchill",
                "Clairmont",
                "Claresholm",
                "Cobourg",
                "Cochrane",
                "Cochrane",
                "Cold Lake",
                "Collingwood",
                "Comox",
                "Coquitlam",
                "Corner Brook",
                "Cornwall",
                "Cornwall",
                "Courtenay",
                "Cowansville",
                "Cranbrook",
                "Dalhousie",
                "Dartmouth",
                "Dauphin",
                "Dawson",
                "Dawson Creek",
                "Delta",
                "Dieppe",
                "Digby",
                "Dorval",
                "Downsview",
                "Drayton Valley",
                "Drumheller",
                "Drummondville",
                "Dryden",
                "Duncan",
                "Edmonton",
                "Edmundston",
                "Edson",
                "Elliot Lake",
                "Enderby",
                "Estevan",
                "Etobicoke",
                "Fairmont Hot Springs",
                "Fernie",
                "Field",
                "Flamborough",
                "Flesherton",
                "Forestville",
                "Fort Assiniboine",
                "Fort Erie",
                "Fort Frances",
                "Fort McMurray",
                "Fort Nelson",
                "Fort Saskatchewan",
                "Fort St John",
                "Fredericton",
                "French Village",
                "Gananoque",
                "Gander",
                "Gaspe",
                "Gatineau",
                "Georgetown",
                "Georgetown",
                "Gibsons",
                "Gimli",
                "Glace Bay",
                "Gloucester",
                "Goffs",
                "Golden",
                "Grand Forks",
                "Grande Cache",
                "Grande Prairie",
                "Gravenhurst",
                "Grimsby",
                "Guelph",
                "Haliburton",
                "Halifax",
                "Hamilton",
                "Hanna",
                "Harrison Hot Springs",
                "Hawkesbury",
                "Hedley",
                "High Level",
                "High River",
                "Hinton",
                "Hope",
                "Hubbards",
                "Hull",
                "Hunter River",
                "Huntsville",
                "Ingersoll",
                "Ingonish",
                "Inuvik",
                "Invermere",
                "Iqaluit",
                "Irricana",
                "Jasper",
                "Jonquiere",
                "Jordan",
                "Kamloops",
                "Kananaskis Village",
                "Kanata",
                "Kapuskasing",
                "Kelowna",
                "Kemptville",
                "Kenora",
                "Kensington",
                "Keremeos",
                "Killarney",
                "Kimberley",
                "Kincardine",
                "Kindersley",
                "Kingsport",
                "Kingston",
                "Kingston",
                "Kirkland Lake",
                "Kitchener",
                "La Malbaie",
                "Lacombe",
                "Ladysmith",
                "Lake Louise",
                "Langley",
                "Laval",
                "Leamington",
                "Leduc",
                "Lethbridge",
                "Levis",
                "Lillooet",
                "Lloydminster",
                "Lockeport",
                "London",
                "Longueuil",
                "Louisbourg",
                "Lund",
                "Lunenburg",
                "Mactier",
                "Magog",
                "Maple Ridge",
                "Marathon",
                "Markham",
                "Marystown",
                "Matane",
                "Mayfield",
                "Meadow Lake",
                "Medicine Hat",
                "Melfort",
                "Melville",
                "Merritt",
                "MŽtis-Sur-Mer",
                "Midland",
                "Milton",
                "Miramichi",
                "Mission",
                "Mississauga",
                "Moncton",
                "Mont Laurier",
                "Mont Tremblant",
                "Montague",
                "Montebello",
                "Montreal",
                "Moose Jaw",
                "Morden",
                "Morell",
                "Morris",
                "Mount Hope",
                "Murray River",
                "Muskoka",
                "Nanaimo",
                "Napanee",
                "Natashquan",
                "Neils Harbour",
                "Nelson",
                "Nepean",
                "New Glasgow",
                "New Liskeard",
                "New Westminster",
                "Newmarket",
                "Niagara Falls",
                "Niagara-on-the-Lake",
                "Nisku",
                "Nordegg",
                "North Battleford",
                "North Bay",
                "North Rustico",
                "North Sydney",
                "North Vancouver",
                "North York",
                "Oakville",
                "Okotoks",
                "Olds",
                "Orangeville",
                "Orford",
                "Orillia",
                "Oshawa",
                "Osoyoos",
                "Ottawa",
                "Owen Sound",
                "Panorama",
                "Parksville",
                "Parry Sound",
                "Peace River",
                "Pelee Island",
                "Pemberton",
                "Pembroke",
                "Penticton",
                "Perce",
                "Perth",
                "Petawawa",
                "Peterborough",
                "Petite Rivire St-Franois",
                "Pickering",
                "Picton",
                "Pictou",
                "Pincher Creek",
                "Pitt Meadows",
                "Pointe Claire",
                "Port Alberni",
                "Port aux Basques",
                "Port Carling",
                "Port Coquitlam",
                "Port Elgin",
                "Port Hardy",
                "Port Hastings",
                "Port Hope",
                "Port Loring",
                "Port Moody",
                "Port Perry",
                "Portage La Prairie",
                "Powell River",
                "Prince Albert",
                "Prince George",
                "Prince Rupert",
                "Princeton",
                "Qualicum Beach",
                "Quebec City",
                "Queensland",
                "Quesnel",
                "Radium Hot Springs",
                "Rankin Inlet",
                "Red Deer",
                "Regina",
                "Resolute",
                "Revelstoke",
                "Rexdale",
                "Richmond",
                "Richmond Hill",
                "Ridgetown",
                "Rimouski",
                "Riviere Du Loup",
                "Roberval",
                "Rock Forest",
                "Rocky Mountain House",
                "Rogers Pass",
                "Rossland",
                "Rouyn Noranda",
                "Saanichton",
                "Sackville",
                "Saint John",
                "Saint-Grgoire",
                "Saint-Joseph-de-la-Rive",
                "Sainte Catherine",
                "Sainte-Adele",
                "Sainte-Foy",
                "Salmon Arm",
                "Saltspring Island",
                "Sarnia",
                "Saskatoon",
                "Sault Ste Marie",
                "Scarborough",
                "Schomberg",
                "Sechelt",
                "Sept-ëles",
                "Shawinigan",
                "Shemogue",
                "Sherbrooke",
                "Sherwood Park",
                "Sicamous",
                "Sidney",
                "Simcoe",
                "Sioux Lookout",
                "Slave Lake",
                "Smithers",
                "Smiths Falls",
                "Squamish",
                "St Albert",
                "St Andrews",
                "St Bride's",
                "St Brides",
            	"St Catharines",
                "St Jerome",
                "St Jovite",
                "St Laurent",
                "St Martins",
                "St Thomas",
                "St-sauveur",
                "St. Georges De Beauce",
                "St. Jean-Sur-Richelieu",
                "St. John's canada",
                "St. Johns canada",
            	"St. Liboire",
                "St. Paul",
                "Ste Anne De Beaupre",
                "Ste-helene-de-bagot",
                "Stephenville",
                "Stettler",
                "Stony Plain",
                "Stratford",
                "Stratford",
                "Strathmore",
                "Sudbury",
                "Summerside",
                "Sun Peaks",
                "Sundridge",
                "Surrey",
                "Sussex",
                "Swan River",
                "Swift Current",
                "Sydney",
                "Taber",
                "Tadoussac",
                "Terrace",
                "Thamesford",
                "The Pas",
                "Thetford Mines",
                "Thompson",
                "Thorold",
                "Three Hills",
                "Thunder Bay",
                "Tignish",
                "Tillsonburg",
                "Timmins",
                "Tofino",
                "Toronto",
                "Trail",
                "Trenton",
                "Trois Rivires",
                "Truro",
                "Ucluelet",
                "Val D'or",
                "Val-des-Lacs",
                "Valemount",
                "Vancouver",
                "Vanderhoof",
                "Vaudreuil",
                "Vaughan",
                "Vermilion",
                "Vernon",
                "Victoria",
                "Wallaceburg",
                "Walton",
                "Wasaga Beach",
                "Waterloo",
                "Waterton Lakes",
                "Wawa",
                "Welland",
                "West Vancouver",
                "Westbank",
                "Western Shore",
                "Wetaskiwin",
                "Weyburn",
                "Whistler",
                "Whitby",
                "White Rock",
                "Whitecourt",
                "Whitehorse",
                "Wiarton",
                "Williams Lake",
                "Windsor",
                "Winfield",
                "Winkler",
                "Winnipeg",
                "Witless Bay",
                "Wolfville",
                "Woodstock",
                "Woodstock",
                "Yarmouth",
                "Yellowknife",
                "Yorkton",
                "canada",
                "Canada",
                "Alberta",
                "British Columbia",
                "Manitoba",
                "New Brunswick",
                "Newfoundland and Labrador",
                "Nova Scotia",
                "Ontario",
                "Prince Edward Island",
                "Quebec",
                "Saskatchewan",
                "Northwest Territories",
                "Nunavut",
                "Yukon",
            );
        }
/*
 * 
 */        
        $idx = mt_rand(0, count( $names ) - 1);
        return trim($names[ $idx ]);
    }
    
    public function create(){
        $dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        if( !empty( $this->username ) && !empty( $this->password ) ){
            $data = (object) array(
                'username' => $this->username,
                'password' => $this->password,
                'network' => $this->network,
            );
            
            if( !empty($this->email) ){
                $data->email = $this->email;
            }
            
            if( !empty($this->extra) ){
                $data->extra = json_encode($this->extra);
            }
            
            $dao->create($data);
            return new self( $data->username );
        }
    }
    
    public function update( $network, $data ){
        
        $data->network = $network;
        $data->name = $this->name;
        
        $dao = new BIM_DAO_Mysql_Persona( BIM_Config::db() );
        $dao->update($data);
        
        foreach( $data as $prop => $value ){
            $this->$network->$prop = $data;
        }
    }
}
