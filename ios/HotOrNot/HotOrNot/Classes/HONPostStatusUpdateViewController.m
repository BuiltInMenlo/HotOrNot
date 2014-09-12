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
@end

@implementation HONPostStatusUpdateViewController

- (id)init {
	if ((self = [super init])) {
		_offset = 0;
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

			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm your moji update:"
																message:[[_emojiTextView.text substringToIndex:MIN([_emojiTextView.text length], 42)] stringByAppendingString:([_emojiTextView.text length] > 42) ? @"…" : @""]
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
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Compose"];
	[self.view addSubview:_headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(0.0, 19.0, 44.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:cancelButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 40.0, 1.0, 44.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:submitButton];
	
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 81.0, 304.0, 42)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	[_placeholderLabel setTextColor:[UIColor lightGrayColor]];
	_placeholderLabel.font = [UIFont systemFontOfSize:36.0f];
	_placeholderLabel.text = @"Type emoji...";
	[self.view addSubview:_placeholderLabel];
	
	_emojiTextView = [[UITextView alloc] initWithFrame:CGRectMake(13.0, 72.0, 304.0, self.view.frame.size.height - 288)];
	_emojiTextView.backgroundColor = [UIColor clearColor];
	[_emojiTextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emojiTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emojiTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emojiTextView setReturnKeyType:UIReturnKeyDone];
	[_emojiTextView setTextColor:[UIColor blackColor]];
	_emojiTextView.font = [UIFont systemFontOfSize:40.0f];
	_emojiTextView.keyboardType = UIKeyboardTypeDefault;
	_emojiTextView.text = @"";
	_emojiTextView.delegate = self;
	[self.view addSubview:_emojiTextView];
	
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Compose View - Entering"];
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"in_compose"] isEqualToString:@"YES"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"in_compose"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		NSLog(@"^^^^^^IN COMPOSE MODAL^^^^^^");
	} //sets key to YES so that app knows it's in the compose modal already when resuming from background
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	[_emojiTextView becomeFirstResponder];
}



#pragma mark - Navigation
- (void)_goCancel {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Compose View - Cancel"];
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"in_compose"];
	NSLog(@"^^^^^^NOT IN COMPOSE MODAL^^^^^^");
	
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (void)_goSubmit {
	_isSubmitting = YES;
	[_emojiTextView resignFirstResponder];
}


#define kACCEPTABLE_CHARACTERS @"😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹"
#pragma mark - TextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSLog(@"textView:[%@] shouldChangeTextInRange:[%@] replacementText:[%@] -- (%@)", textView.text, NSStringFromRange(range), text, NSStringFromRange([text rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:kACCEPTABLE_CHARACTERS] invertedSet]]));
	
	NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:kACCEPTABLE_CHARACTERS] invertedSet];
	
	if([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return (NO);
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Compose View - Enter %@Unicode Char", ([text rangeOfCharacterFromSet:invalidCharSet].location == NSNotFound) ? @"" : @"Non-"] withStringChar:text];
	
	if ([text rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound) {
		[[[UIAlertView alloc] initWithTitle:@"This app requires you to use the Emoji iOS 8 Keyboard!"
									message:nil
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		NSLog(@"This string contains illegal characters");
	}
	
	return ([text rangeOfCharacterFromSet:invalidCharSet].location == NSNotFound);
}

- (void)textViewDidChange:(UITextView *)textView {
	_placeholderLabel.hidden = ([textView.text length] > 0);
	
	if ([textView.text length] > 0) {
		NSString *lastChar = [textView.text substringFromIndex: [textView.text length] - 2];
		[_headerView setTitle:lastChar];
		
		NSData *utf32 = [lastChar dataUsingEncoding:NSUTF32BigEndianStringEncoding]; //Unicode Code Point
		NSString *uniHex = [[[[[[utf32 description] substringWithRange:NSMakeRange(1, [[utf32 description] length] - 2)] componentsSeparatedByString:@" "] lastObject] substringFromIndex:3] uppercaseString];
		NSString *uniFormat = [@"U+" stringByAppendingString:uniHex];
		
		NSLog(@"Character (%@) = [%@] /// {%@}", lastChar, uniFormat, [utf32 description]);//@"\U0001F604");

	} else
		[_headerView setTitle:@"Compose"];
	
	
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
