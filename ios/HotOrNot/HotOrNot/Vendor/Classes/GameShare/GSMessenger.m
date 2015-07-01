//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessenger.h"


@implementation GSMessenger

static GSMessenger *sharedInstance = nil;
+ (GSMessenger *)sharedInstance {
	static GSMessenger *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if((self = [super init]) != nil) {
		_selectedTypes = [NSMutableArray array];
		_supportedTypes = [NSArray arrayWithObjects:@(GSMessengerTypeFBMessenger), @(GSMessengerTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerTypeSMS), @(GSMessengerTypeWhatsApp), @(GSMessengerTypeWeChat), @(GSMessengerTypeHike), @(GSMessengerTypeOTHER), nil];
		
		if (_gsViewController == nil)
			_gsViewController = [[GSCollectionViewController alloc] init];
	}
	
	return (self);
}

- (void)addAllMessengerTypes {
	[self addMessengerTypes:_supportedTypes];
}

- (void)addMessengerType:(GSMessengerType)messengerType {
	[_selectedTypes addObject:@(messengerType)];
	[_gsViewController addMessengerType:messengerType];
}

- (void)addMessengerTypes:(NSArray *)messengerTypes {
	[messengerTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSMessengerType messengerType = (GSMessengerType)[(NSNumber *)obj intValue];
		[self addMessengerType:messengerType];
	}];
}

- (void)showMessengersWithViewController:(UIViewController *)viewController  {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_gsViewController];
	[navigationController setNavigationBarHidden:YES];
	[viewController presentViewController:navigationController animated:YES completion:^(void) {
	}];
}

- (void)showMessengersWithViewController:(UIViewController *)viewController usingDelegate:(id<GSCollectionViewControllerDelegate>)delegate {
	[self setDelegate:delegate];
	[self showMessengersWithViewController:viewController];
}

- (void)setDelegate:(id<GSCollectionViewControllerDelegate>)delegate {
	if (_gsViewController.delegate != nil)
		_gsViewController = nil;
	
	_delegate = delegate;
	_gsViewController.delegate = _delegate;
}

- (NSArray *)selectedTypes {
	return (_selectedTypes);
}

- (NSArray *)supportedTypes {
	return (_supportedTypes);
}


@end
