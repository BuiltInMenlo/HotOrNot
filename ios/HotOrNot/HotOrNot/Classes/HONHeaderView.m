//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

const CGRect kNormalFrame = {-480.0f, -86.0f, 1280.0f, 256.0f};
const CGRect kActiveFrame = {0.01f, 0.01f, 0.01f, 0.01f};


@interface HONHeaderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView
@synthesize title = _title;

- (id)initWithBranding {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), (CGRectGetWidth([UIScreen mainScreen].bounds) / 5))])) {
		_bgImageView = [[UIImageView alloc] initWithFrame: self.frame];
		_bgImageView.image = [UIImage imageNamed:@"navHeaderMoji"];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (id)initWithDetail:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orangeBackgroundBlank"]];
		[self addSubview:_bgImageView];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320, 64.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18.0];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBG"]];
		[self addSubview:_bgImageView];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-480.0, -90.0, 1280.0, 256.0)]; //size of label is x4 because scaled down by 0.25
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:75.0];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		_titleLabel.transform = CGAffineTransformScale(_titleLabel.transform, 0.25, 0.25);
		[self addSubview:_titleLabel];
	}
	
	return (self);
}


#define ACCEPTABLE_CHARACTERS @"😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤️💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐️☀️⛅️☁️⚡️☔️❄️⛄️🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎️📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛️⏰⌚️🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉️📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂️📌📎✒️✏️📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄️🎲🎯🏈🏀⚽️⚾️🎾🎱🏉🎳⛳️🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕️🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪️🏬🏤🌇🌆🏯🏰⛺️🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲️🎢🚢⛵️🚤🚣⚓️🚀✈️💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠️🚧🔰⛽️🏮🎰♨️🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣0️⃣🔟🔢#️⃣🔣⬆️⬇️⬅️➡️🔠🔡🔤↗️↖️↘️↙️↔️↕️🔄◀️▶️🔼🔽↩️↪️ℹ️⏪⏩⏫⏬⤵️⤴️🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯️🈳🈵🈴🈲🉐🈹🈺🈶🈚️🚻🚹🚺🚼🚾🚰🚮🅿️♿️🚭🈷🈸🈂Ⓜ️🛂🛄🛅🛃🉑㊙️㊗️🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔️✳️❇️❎✅✴️💟🆚📳📴🅰🅱🆎🅾💠➿♻️♈️♉️♊️♋️♌️♍️♎️♏️♐️♑️♒️♓️⛎🔯🏧💹💲💱©®™❌‼️⁉️❗️❓❕❔⭕️🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦✖️➕➖➗♠️♥️♣️♦️💮💯✔️☑️🔘🔗➰〰〽️🔱◼️◻️◾️◽️▪️▫️🔺🔲🔳⚫️⚪️🔴🔵🔻⬜️⬛️🔶🔷🔸🔹"
- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
	
//	if ([_title rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS]].location != NSNotFound) {
//		CGSize scaleSize = CGSizeMake(kActiveFrame.size.width / kNormalFrame.size.width, kActiveFrame.size.height / kNormalFrame.size.height);
//		CGPoint offsetPt = CGPointMake(CGRectGetMidX(kActiveFrame) - CGRectGetMidX(kNormalFrame), CGRectGetMidY(kActiveFrame) - CGRectGetMidY(kNormalFrame));
//		CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
//		
//		[UIView animateWithDuration:0.125 delay:0.000
//			 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
//							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//		 
//						 animations:^(void) {
//							 _titleLabel.transform = transform;
//						 } completion:^(BOOL finished) {
//							 CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
//							 [UIView animateWithDuration:0.250 delay:0.000
//								  usingSpringWithDamping:0.250 initialSpringVelocity:0.750
//												 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//							  
//											  animations:^(void) {
//												  _titleLabel.transform = transform;
//												  _titleLabel.transform = CGAffineTransformScale(_titleLabel.transform, 0.25, 0.25);
//											  } completion:^(BOOL finished) {
//											  }];
//						 }];
//	}
}

- (void)setFont:(UIFont *)font {
	_titleLabel.font = font;
}

- (void)setTransform:(CGAffineTransform)transform {
	_titleLabel.transform = transform;
}


- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 19.0);
	[self addSubview:buttonView];
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}


@end
