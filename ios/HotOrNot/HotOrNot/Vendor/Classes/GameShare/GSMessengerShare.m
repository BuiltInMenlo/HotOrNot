//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessengerShare.h"

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

@implementation GSMessengerShare
@synthesize delegate = _delegate;

#pragma mark - Singletion Creation
static GSMessengerShare *sharedInstance = nil;
+ (GSMessengerShare *)sharedInstance {
	static GSMessengerShare *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}


#pragma mark - Static Methods
+ (NSArray *)selectedMessengerTypes {
	return ([[GSMessengerShare sharedInstance] selectedTypes]);
}

+ (NSArray *)supportedMessengerTypes {
	return ([[GSMessengerShare sharedInstance] supportedTypes]);
}


- (id)init {
	if((self = [super init]) != nil) {
		_selectedTypes = [NSMutableArray array];
//		_supportedTypes = [NSArray arrayWithObjects:@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeOTHER), nil];
		_supportedTypes = [[NSArray arrayWithObjects:@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerShareTypeKik), @(GSMessengerShareTypeLine), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeViber), nil] sortedArrayUsingSelector:@selector(compare:)];
		
		if (_gsViewController == nil)
			_gsViewController = [[GSCollectionViewController alloc] init];
		
		_vcDelegate = self;
		_gsViewController.delegate = _vcDelegate;
	}
	
	return (self);
}


#pragma mark - Data Handling
- (void)addAllMessengerShareTypes {
	[self addMessengerShareTypes:[[GSMessengerShare sharedInstance] supportedTypes]];
}

- (void)addMessengerShareType:(GSMessengerShareType)messengerShareType {
	if ([_supportedTypes containsObject:@(messengerShareType)]) {
		[_selectedTypes addObject:@(messengerShareType)];
		[_gsViewController addMessengerShareType:messengerShareType];
	}
}

- (void)addMessengerShareTypes:(NSArray *)messengerShareTypes {
	[messengerShareTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSMessengerShareType messengerShareType = (GSMessengerShareType)[(NSNumber *)obj intValue];
		[self addMessengerShareType:messengerShareType];
	}];
}

- (void)overrrideWithOutboundURL:(NSString *)outboundURL {
	[_gsViewController setOutboundURL:outboundURL];
}


#pragma mark - UI Presentation
- (void)dismissMessengerSharePicker {
	[_gsViewController dismissViewControllerAnimated:NO completion:^(void){}];
}

- (void)showMessengerSharePickerOnViewController:(UIViewController *)viewController  {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_gsViewController];
	[navigationController setNavigationBarHidden:YES];
	[viewController presentViewController:navigationController animated:NO completion:^(void) {
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
		[self.delegate didSelectMessengerWithType:(GSMessengerShareType)messengerVO.messengerID];
}

- (void)gsCollectionViewDidClose:(GSCollectionViewController *)viewController {
	NSLog(@"[*:*] gsCollectionViewDidClose [*:*]");
	
	if ([self.delegate respondsToSelector:@selector(didCloseMessengerShare)])
		[self.delegate didCloseMessengerShare];
}

- (void)gsCollectionViewDidSkip:(GSCollectionViewController *)viewController {
	NSLog(@"[*:*] gsCollectionViewDidSkip: [*:*]");
	
	if ([self.delegate respondsToSelector:@selector(didSkipMessengerShare)])
		[self.delegate didSkipMessengerShare];
}

@end
