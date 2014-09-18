//
//  HONPostStatusUpdateViewController.m
//  HotOrNot
//
//  Created by Anirudh Agarwala on 9/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONPostStatusUpdateViewController.h"
#import "HONHeaderView.h"

@interface HONPostStatusUpdateViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UITextView *emojiTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) NSString *unicodeEmojis;
@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) NSUInteger offset;
@property (nonatomic, strong) NSString *currentCharacter;
@property (nonatomic, strong) UIImageView *introModal;
@property (nonatomic, strong) UIImageView *introTint;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *animation1;
@property (nonatomic, strong) UIImageView *animation2;
@property (nonatomic, strong) UIImageView *animation3;
@end

@implementation HONPostStatusUpdateViewController

- (id)init {
	if ((self = [super init])) {
		_offset = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_completedFirstRun:) name:@"COMPLETED_FIRST_RUN" object:nil];
    }
	
    return (self);
}


#pragma mark - Data Calls
- (void)_submitStatusUpdate {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submit", @"Submitting…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_unicodeEmojis = @"";
	NSMutableArray *emojis = [NSMutableArray array];
	for (int i=0; i<[_emojiTextView.text length]; i+=2) {
		NSString *emojiChar = [_emojiTextView.text substringWithRange:NSMakeRange(i, 2)];
		[emojis addObject:emojiChar];
		
		NSData *utf32 = [emojiChar dataUsingEncoding:NSUTF32BigEndianStringEncoding]; //Unicode Code Point
		_unicodeEmojis = [_unicodeEmojis stringByAppendingString:[@"\\U000" stringByAppendingString:[[[[[[utf32 description] substringWithRange:NSMakeRange(1, [[utf32 description] length] - 2)] componentsSeparatedByString:@" "] lastObject] substringFromIndex:3] lowercaseString]]];
	}
	
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Compose View - Submit Update"
									  withCharArray:emojis];
	
	NSError *error;
	NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:emojis options:0 error:&error]
												 encoding:NSUTF8StringEncoding];
	
	NSDictionary *submitParams = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
								   @"img_url"		: [[HONClubAssistant sharedInstance] defaultClubPhotoURL],
								   @"club_id"		: [@"" stringFromInt:[[HONClubAssistant sharedInstance] userSignupClub].clubID],
								   @"owner_id"		: [@"" stringFromInt:[[HONClubAssistant sharedInstance] userSignupClub].ownerID],
								   @"subject"		: @"",
								   @"subjects"		: jsonString,
								   @"challenge_id"	: @"0",
								   @"recipients"	: @"",
								   @"api_endpt"		: kAPICreateChallenge};
	NSLog(@"SUBMIT PARAMS:[%@]", submitParams);
	
	[[NSUserDefaults standardUserDefaults] setValue:emojis forKey:@"last_emojis"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:submitParams completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
		
		} else {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONClubAssistant sharedInstance] defaultClubPhotoURL]
															   forBucketType:HONS3BucketTypeSelfies
																  completion:nil];

			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm your moji update:\n\n"
																message:[[_emojiTextView.text substringToIndex:MIN([_emojiTextView.text length], 42)] stringByAppendingString:([_emojiTextView.text length] > 42) ? @"…\n" : @"\n"]
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"Send to all contacts", @"Send to all moji friends", nil, nil];
			[alertView setTag:1];
			[alertView show];
			
		}
	}];
}



#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_isSubmitting = NO;
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"New Update"];
	[self.view addSubview:_headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(5.0, 19.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:cancelButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 64.0, 1.0, 64.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"sendButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"sendButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:submitButton];
	
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 180.0, 320.0, 20)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	[_placeholderLabel setTextColor:[UIColor colorWithRed:0.69 green:0.698 blue:0.71 alpha:1]];
	_placeholderLabel.font = [UIFont systemFontOfSize:18.0f];
	_placeholderLabel.text = @"( select emoji )";
	_placeholderLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:_placeholderLabel];
	
	_emojiTextView = [[UITextView alloc] initWithFrame:CGRectMake(13.0, 64.0, 304.0, self.view.frame.size.height - 280)];
	_emojiTextView.backgroundColor = [UIColor clearColor];
	[_emojiTextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emojiTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emojiTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emojiTextView setTextColor:[UIColor blackColor]];
	_emojiTextView.font = [UIFont systemFontOfSize:55.0f];
	_emojiTextView.keyboardType = UIKeyboardTypeDefault;
	_emojiTextView.text = @"";
	_emojiTextView.delegate = self;
	[self.view addSubview:_emojiTextView];
	
	
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Compose View - Entering"];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"intro_modal"] isEqualToString:@"YES"]) {
		NSLog(@"^^^^^^^^^^^^^^^ENTERED COMPOSE AFTER FIRST RUN^^^^^^^^^^^^^^^");
		_emojiTextView.userInteractionEnabled = NO; //disallows user from focusing on textview behind intro modal
		
		_introTint= [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_introTint.image = [UIImage imageNamed:@"darkBackgroundTint"];
		[self.view addSubview:_introTint]; //intro background tint
		
		_introModal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modalBackgroundOrange"]];
		_introModal.frame = CGRectOffset(_introModal.frame, 0.0, 568.0);
		[self.view addSubview:_introModal]; //intro modal explaining app
		
		[UIView animateWithDuration:0.75f delay:0.0f options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
						 animations:^{
							 _introModal.frame = CGRectOffset(_introModal.frame, 0.0, -568.0);
						 }
						 completion:^(BOOL finished){
							 NSLog( @"Intro Modal Animated" );
							 _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
							 _closeButton.frame = CGRectMake(250.0, 70.0, 44.0, 44.0);
							 [_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
							 [_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
							 [_closeButton addTarget:self action:@selector(_goCloseModal) forControlEvents:UIControlEventTouchUpInside];
							 //[_closeButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
							 [self.view addSubview:_closeButton]; //cancel button for intro modal
						 }];
		
		_animation1= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textAnimation1"]];
		_animation1.frame = CGRectOffset(_animation1.frame, 0.0, 178.0);
		_animation1.alpha = 0.0;
		[self.view addSubview:_animation1]; //textAnimation1 for intro modal
		
		_animation2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textAnimation2"]];
		_animation2.frame = CGRectOffset(_animation2.frame, 0.0, 178.0);
		_animation2.alpha = 0.0;
		[self.view addSubview:_animation2]; //textAnimation2 for intro modal
		
		_animation3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textAnimation3"]];
		_animation3.frame = CGRectOffset(_animation3.frame, 0.0, 178.0);
		_animation3.alpha = 0.0;
		[self.view addSubview:_animation3]; //textAnimation3 for intro modal
		
		[self _animationLoop]; //looping text animations
		
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"intro_modal"]; //prohibits intro modal from showing after first run
	} //displays intro modal ONLY if first run
	
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}



#pragma mark - Navigation
- (void)_goCancel {
	[_emojiTextView resignFirstResponder];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Compose View - Cancel"];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (void)_goSubmit {
	_isSubmitting = YES;
	[_emojiTextView resignFirstResponder];
}

- (void)_goCloseModal {
	_introModal.hidden = YES;
	_introTint.hidden = YES;
	_closeButton.hidden = YES;
	_animation1.hidden = YES;
	_animation2.hidden = YES;
	_animation3.hidden = YES;
	_emojiTextView.userInteractionEnabled = YES;
	[_emojiTextView becomeFirstResponder];
}

- (void)_animationLoop {
	[UIView animateWithDuration:0.5f delay:1.25f options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 _animation1.alpha = 1.0;
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.5f delay:1.0f options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
										  animations:^{
											  _animation1.alpha = 0.0;
										  }
										  completion:^(BOOL finished){ //ANIMATION 1 END
											  [UIView animateWithDuration:0.5f delay:0.0f options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
															   animations:^{
																   _animation2.alpha = 1.0;
															   }
															   completion:^(BOOL finished){
																   [UIView animateWithDuration:0.5f delay:1.0f options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
																					animations:^{
																						_animation2.alpha = 0.0;
																					}
																					completion:^(BOOL finished){ //ANIMATION 2 END
																						[UIView animateWithDuration:0.5f delay:0.0f options: UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
																										 animations:^{
																											 _animation3.alpha = 1.0;
																										 }
																										 completion:^(BOOL finished){
																											 [UIView animateWithDuration:0.5f delay:1.0f options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
																															  animations:^{
																																  _animation3.alpha = 0.0;
																															  }
																															  completion:^(BOOL finished){ //ANIMATION 3 END
																																  [self _animationLoop];
					
																															  }];
																										 }];
																					}];
															   }];
										  }];
					 }];
}


#define kACCEPTABLE_CHARACTERS @"\n😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹"
#pragma mark - TextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSLog(@"textView:[%@] shouldChangeTextInRange:[%@] replacementText:[%@] -- (%@)", textView.text, NSStringFromRange(range), text, NSStringFromRange([text rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:kACCEPTABLE_CHARACTERS] invertedSet]]));
	_currentCharacter = text;
	
	NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:kACCEPTABLE_CHARACTERS] invertedSet];
	
	if([text isEqualToString:@"\n"]) {
		NSLog(@"!!!!!!!!!!!!!!!!WORK2!!!!!!!!!!!!!!");
		return YES;
	}
	NSLog(@"!!!!!!!!!!!!!!!!WORK!!!!!!!!!!!!!!");

	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Compose View - Enter %@Unicode Char", ([text rangeOfCharacterFromSet:invalidCharSet].location == NSNotFound) ? @"" : @"Non-"] withStringChar:text];
	
	if ([text rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound) {
		[[[UIAlertView alloc] initWithTitle:@"This app requires you to use the Emoji iOS Keyboard!"
									message:nil
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		NSLog(@"This string contains illegal characters");
	}
	
	return ([text rangeOfCharacterFromSet:invalidCharSet].location == NSNotFound);
//	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	_placeholderLabel.hidden = ([textView.text length] > 0);
	
	NSLog(@"%@", textView.text);
	if (([textView.text length] > 0) && (![_currentCharacter isEqualToString:@"\n"])) {
		NSLog(@"~~~~~~~~~DOES IT COME HERE 2~~~~~~~~~~");
//		[_headerView setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:40]];
		
		NSString *lastChar = [textView.text substringFromIndex: [textView.text length] - 2];
		[_headerView setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:152.0]];
		[_headerView setTitle:lastChar];
		
		NSData *utf32 = [lastChar dataUsingEncoding:NSUTF32BigEndianStringEncoding]; //Unicode Code Point
		NSString *uniHex = [[[[[[utf32 description] substringWithRange:NSMakeRange(1, [[utf32 description] length] - 2)] componentsSeparatedByString:@" "] lastObject] substringFromIndex:3] uppercaseString];
		NSString *uniFormat = [@"U+" stringByAppendingString:uniHex];
		
		NSLog(@"Character (%@) = [%@] /// {%@}", lastChar, uniFormat, [utf32 description]);//@"\U0001F604");

	}
	
	else if ([textView.text length] > 2) {
		NSLog(@"~~~~~~~~~DOES IT COME HERE~~~~~~~~~~");
//		NSString *lastChar = [textView.text substringWithRange:NSMakeRange([textView.text length] - 3, 1)];
//		[_headerView setTitle:lastChar];
		
//		[_headerView setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18]];
	}
	
	else {
		[_headerView setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:75.0]];
		[_headerView setTitle:@"New Update"];
	}
	
//	NSLog(@"textView:[%@](%u)--{%d}", textView.text, [textView.text length], _offset);
//	NSString *lastChar = ([textView.text length] > 0) ? [textView.text substringFromIndex:[textView.text length]  - _offset] : @"";
//	[_headerView setTitle:([lastChar length] > 0) ? lastChar : @"Compose"];
	

//	int codeValue = strtol([lastChar UTF8String], NULL, 16);
//	NSUInteger codeValue;
//	[[NSScanner scannerWithString:lastChar] scanHexInt:&codeValue];
//	NSLog(@"Character (%@) = [\\u%x] (%d)", lastChar, (unichar)codeValue, codeValue);

//	NSData *u = [lastChar dataUsingEncoding:NSUTF32StringEncoding]; //UTF-32LE (hex)
//	NSData *u = [lastChar dataUsingEncoding:NSUTF32LittleEndianStringEncoding]; //UTF-32LE (hex)
//	NSData *utf32 = [lastChar dataUsingEncoding:NSUTF32BigEndianStringEncoding]; //Unicode Code Point
//	NSString *uniHex = [[[[[[utf32 description] substringWithRange:NSMakeRange(1, [[utf32 description] length] - 2)] componentsSeparatedByString:@" "] lastObject] substringFromIndex:3] uppercaseString];
//	NSString *uniFormat = [@"U+" stringByAppendingString:uniHex];
	
//	NSString *emoji = [uniFormat substringFromIndex:[lastChar length]];
//	for (int i=0; i<8-[[uniFormat substringFromIndex:[lastChar length]] length]; i++)
//		emoji = [@"0" stringByAppendingString:emoji];
//	
//	NSLog(@"Character (%@) = [\\u%06x]/[U+%@] (%d) {%@}", lastChar, [lastChar characterAtIndex:0], uniHex, [lastChar characterAtIndex:0], emoji);//@"\U0001F604");
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	_isSubmitting = NO;
	_offset = 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	NSLog(@"textViewDidEndEditing");
	
	if (_isSubmitting) {
		if ([_emojiTextView.text length] > 0)
			[self _submitStatusUpdate];
		
		else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Need to choose an emoji!"
																message:nil
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
													  otherButtonTitles:nil];
			[alertView setTag:0];
			[alertView show];
		}
	}

}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[_emojiTextView becomeFirstResponder];
	}
	
	else if (alertView.tag == 1) {
		NSLog(@"DID SUBMIT -> POP ALERT %d", buttonIndex);
		
		if (buttonIndex == 0)
			[_emojiTextView becomeFirstResponder];
		
		else {
			[[HONClubAssistant sharedInstance] broadcastStatusUpdate:_unicodeEmojis toAllContacts:(buttonIndex == 1)];
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
			}];
		}
	}
}

@end
