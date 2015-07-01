//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessenger.h"

NSString * const kFBMessengerKey	= @"FB_MESSENGER";
NSString * const kKakaoTalkKey		= @"KAKAO_TALK";
NSString * const kKikKey			= @"KIK";
NSString * const kLineKey			= @"LINE";
NSString * const kSMSKey			= @"SMS";
NSString * const kWhatsAppKey		= @"WHATS_APP";
NSString * const kWeChatKey			= @"WE_CHAT";
NSString * const kHikeKey			= @"HIKE";
NSString * const kViberKey			= @"VIBER";
NSString * const kOTHERKey			= @"OTHER";

@implementation GSMessenger
@synthesize delegate = _delegate;

#pragma mark - Singletion Creation
static GSMessenger *sharedInstance = nil;
+ (GSMessenger *)sharedInstance {
	static GSMessenger *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}


#pragma mark - Static Methods
+ (NSArray *)selectedMessengerTypes {
	return ([[GSMessenger sharedInstance] selectedTypes]);
}

+ (NSArray *)supportedMessengerTypes {
	return ([[GSMessenger sharedInstance] supportedTypes]);
}


- (id)init {
	if((self = [super init]) != nil) {
		_selectedTypes = [NSMutableArray array];
//		_supportedTypes = [NSArray arrayWithObjects:@(GSMessengerTypeFBMessenger), @(GSMessengerTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerTypeSMS), @(GSMessengerTypeWhatsApp), @(GSMessengerTypeWeChat), @(GSMessengerTypeHike), @(GSMessengerTypeOTHER), nil];
		_supportedTypes = [[NSArray arrayWithObjects:@(GSMessengerTypeFBMessenger), @(GSMessengerTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerTypeSMS), @(GSMessengerTypeWhatsApp), @(GSMessengerTypeWeChat), @(GSMessengerTypeHike), @(GSMessengerTypeViber), nil] sortedArrayUsingSelector:@selector(compare:)];
		
		if (_gsViewController == nil)
			_gsViewController = [[GSCollectionViewController alloc] init];
		
		_vcDelegate = self;
		_gsViewController.delegate = _vcDelegate;
	}
	
	return (self);
}


#pragma mark - Data Handling
- (void)addAllMessengerTypes {
	[self addMessengerTypes:[[GSMessenger sharedInstance] supportedTypes]];
}

- (void)addMessengerType:(GSMessengerType)messengerType {
	if ([_supportedTypes containsObject:@(messengerType)]) {
		[_selectedTypes addObject:@(messengerType)];
		[_gsViewController addMessengerType:messengerType];
	}
}

- (void)addMessengerTypes:(NSArray *)messengerTypes {
	[messengerTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSMessengerType messengerType = (GSMessengerType)[(NSNumber *)obj intValue];
		[self addMessengerType:messengerType];
	}];
}


#pragma mark - UI Presentation
- (void)showMessengersWithViewController:(UIViewController *)viewController  {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_gsViewController];
	[navigationController setNavigationBarHidden:YES];
	[viewController presentViewController:navigationController animated:YES completion:^(void) {
	}];
}


#pragma mark - Instance -> Static Conversions
- (NSArray *)selectedTypes {
	return (_selectedTypes);
}

- (NSArray *)supportedTypes {
	return (_supportedTypes);
}


#pragma mark - CollectionViewController Delegates
- (void)gsCollectionView:(GSCollectionViewController *)viewController didSelectMessenger:(GSMessengerVO *)messengerVO {
	NSLog(@"[*:*] gsCollectionView:didSelectMessenger:[%@] [*:*]", messengerVO.messengerName);
	
	if ([self.delegate respondsToSelector:@selector(didSelectMessengerWithType:)])
		[self.delegate didSelectMessengerWithType:(GSMessengerType)messengerVO.messengerID];
}

- (void)gsCollectionViewDidClose:(GSCollectionViewController *)viewController {
	NSLog(@"[*:*] gsCollectionViewDidClose [*:*]");
	
	if ([self.delegate respondsToSelector:@selector(didCloseMessenger)])
		[self.delegate didCloseMessenger];
}

- (void)gsCollectionViewDidSkip:(GSCollectionViewController *)viewController {
	NSLog(@"[*:*] gsCollectionViewDidSkip: [*:*]");
	
	if ([self.delegate respondsToSelector:@selector(didSkipMessenger)])
		[self.delegate didSkipMessenger];
}

@end
