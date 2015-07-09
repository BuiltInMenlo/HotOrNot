//
//  GSCollectionViewController.m
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

#import "WXApi.h"

#import "NSString+GameShare.h"

#import "GSCollectionViewController.h"
#import "GSCollectionViewFlowLayout.h"
#import "GSCollectionViewCell.h"

#define VIEW_BG_COLOR			[UIColor colorWithRed:0.133 green:0.875 blue:0.706 alpha:1.00]
#define WIDGET_COLOR			[UIColor colorWithRed:0.110 green:0.608 blue:0.490 alpha:1.00]
#define NAV_NORMAL_COLOR		[UIColor colorWithRed:0.110 green:0.608 blue:0.490 alpha:1.00]
#define NAV_HIGHLIGHTED_COLOR	[UIColor colorWithRed:0.075 green:0.420 blue:0.337 alpha:1.00]

#define NAV_LABEL_FONT			[UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define TITLE_LABEL_FONT		[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]

@interface GSCollectionViewController () <FBSDKMessengerURLHandlerDelegate, GSCollectionViewCellDelegate, WXApiDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, strong) NSString *outboundURL;
@property (nonatomic, strong) NSDictionary *baseShareInfo;
@property (nonatomic, strong) NSMutableArray *messengerSchemas;
@property (nonatomic, strong) NSMutableArray *allMessengers;
@property (nonatomic, strong) NSMutableArray *selectedMessengers;
@property (nonatomic, strong) GSMessengerVO *selectedMessengerVO;
@property (nonatomic) GSMessengerShareType selectedMessengerType;
@property (nonatomic, strong) NSString *selectedMessengerText;
@property (nonatomic, strong) NSDictionary *selectedMessengerContent;

@property (nonatomic, strong) FBSDKMessengerURLHandler *messengerURLHandler;

@end

@implementation GSCollectionViewController
@synthesize delegate = _delegate;
@synthesize metaInfo;

static NSString * const kGSTitleCaption = @"Select a messenger";
static NSString * const kGSSkipButtonCaption = @"Skip";


#pragma mark - Static Methods
+ (CGPoint)collectionViewDimension {
	return (CGPointMake(3, 3));
}

+ (NSArray *)supportedTypes {
	return ([@[@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerShareTypeKik), @(GSMessengerShareTypeLine), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeViber)] sortedArrayUsingSelector:@selector(compare:)]);
//	return (@[@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerShareTypeKik), @(GSMessengerShareTypeLine), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeViber)]);
}


#pragma mark - Creation
- (id)init {
	NSLog(@"[:|:] [%@ - init] [:|:]", self.class);
	
	if ((self = [super init])) {
		_outboundURL = @"";
		_selectedMessengerText = @"";
		_selectedMessengerContent = nil;
		_allMessengers = [NSMutableArray array];
		_selectedMessengers = [NSMutableArray array];
		_messengerSchemas = [NSMutableArray array];
		
		
		[[NSArray arrayWithContentsOfFile:[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GameShareRecources" ofType:@"bundle"]] pathForResource:@"GSMessengers" ofType:@"plist"]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_allMessengers addObject:[GSMessengerVO messengerWithDictionary:(NSDictionary *)obj]];
		}];
		
		_baseShareInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GSMessengerShareInfo"
																									ofType:@"plist"]];
		
		[[NSArray arrayWithContentsOfFile:[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GameShareRecources" ofType:@"bundle"]] pathForResource:@"GSMessengerSchemas" ofType:@"plist"]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_messengerSchemas addObject:(NSDictionary *)obj];
		}];
		
		if ((BOOL)[[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"override"] intValue] && [[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"image_url"] length] > 0) {
			[self _writeWebImageFromURL:[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"image_url"] toUserDefaultsKey:@"kakao_image"];
		}
		
		if ([[_baseShareInfo objectForKey:@"main_image_url"] length] > 0)
			[self _writeWebImageFromURL:[_baseShareInfo objectForKey:@"main_image_url"] toUserDefaultsKey:@"main_image_url"];
		
		if ([[_baseShareInfo objectForKey:@"sub_image_url"] length] > 0)
			[self _writeWebImageFromURL:[_baseShareInfo objectForKey:@"sub_image_url"] toUserDefaultsKey:@"sub_image_url"];
	}
	
	return (self);
}

- (id)initWithAllMessengers {
	NSLog(@"[:|:] [%@ - initWithAllMessengers] [:|:]", self.class);
	if ((self == [self initWithMessengers:[GSCollectionViewController supportedTypes]])) {
	}
	
	return (self);
}

- (id)initWithMessengers:(NSArray *)messengers {
	NSLog(@"[:|:] [%@ - initWithMessengers:%@] [:|:]", self.class, messengers);
	
	if ((self = [self init])) {
		_selectedMessengers = [NSMutableArray array];
		[messengers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			GSMessengerShareType messengerShareType = (GSMessengerShareType)[(NSNumber *)obj intValue];
			if ([[GSCollectionViewController supportedTypes] containsObject:@(messengerShareType)])
				[_selectedMessengers addObject:[self _messengerVOForShareType:messengerShareType]];
		}];
	}
	
	return (self);
}

- (void)addMessengerShareType:(GSMessengerShareType)messengerShareType {
	if ([[GSCollectionViewController supportedTypes] containsObject:@(messengerShareType)])
		[_selectedMessengers addObject:[self _messengerVOForShareType:messengerShareType]];
}

- (void)setOutboundURL:(NSString *)outboundURL {
	_outboundURL = outboundURL;
}


#pragma mark - Destruction
-(void)dealloc {
	NSLog(@"[:|:] [%@ - dealloc] [:|:]", self.class);
	
	[[_collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSCollectionViewCell *cell = (GSCollectionViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_messengerURLHandler.delegate = nil;
	
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
	
	[_allMessengers removeAllObjects];
	_allMessengers = nil;
	
	[_selectedMessengers removeAllObjects];
	_selectedMessengers = nil;
	
	_selectedMessengerVO = nil;
}


#pragma mark - Memory Handling
- (void)didReceiveMemoryWarning {
	NSLog(@"[:|:] [%@ - didReceiveMemoryWarning] [:|:]", self.class);
	
	[super didReceiveMemoryWarning];
}


#pragma mark - View LifeCycle
- (void)loadView {
	NSLog(@"[:|:] [%@ - loadView] [:|:]", self.class);
	
	[super loadView];
	[self.view setBackgroundColor:VIEW_BG_COLOR];
}

- (void)viewDidLoad {
	NSLog(@"[:|:] [%@ - viewDidLoad] [:|:]", self.class);
	
	[super viewDidLoad];
	CGSize collectionViewSize = CGSizeMake(([GSCollectionViewController collectionViewDimension].x * kGSCollectionViewCellSize.width) + (([GSCollectionViewController collectionViewDimension].x - 1) * kGSCollectionViewCellSpacing.width), ([GSCollectionViewController collectionViewDimension].y * kGSCollectionViewCellSize.height) + ([GSCollectionViewController collectionViewDimension].y * kGSCollectionViewCellSpacing.height));
	CGPoint collectionViewOrigin = CGPointMake((self.view.bounds.size.width - collectionViewSize.width) * 0.5, (self.view.bounds.size.height - collectionViewSize.height) * 0.5);
	
	_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(collectionViewOrigin.x, collectionViewOrigin.y, collectionViewSize.width, collectionViewSize.height) collectionViewLayout:[[GSCollectionViewFlowLayout alloc] init]];
	[_collectionView registerClass:[GSCollectionViewCell class] forCellWithReuseIdentifier:[GSCollectionViewCell cellReuseIdentifier]];
	[_collectionView setBackgroundColor:VIEW_BG_COLOR];
	[_collectionView setContentInset:UIEdgeInsetsZero];
	_collectionView.showsHorizontalScrollIndicator = NO;
	_collectionView.showsVerticalScrollIndicator = NO;
	_collectionView.alwaysBounceHorizontal = NO;
	_collectionView.alwaysBounceVertical = NO;
	_collectionView.dataSource = self;
	_collectionView.delegate = self;
	[self.view addSubview:_collectionView];
	
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.5;
	_lpGestureRecognizer.delegate = self;
	_lpGestureRecognizer.delaysTouchesBegan = YES;
	[_collectionView addGestureRecognizer:_lpGestureRecognizer];
	
	_label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 152.0) * 0.5, _collectionView.frame.origin.y - (20.0 + 15.0), 152.0, 20.0)];
	_label.font = TITLE_LABEL_FONT;
	_label.backgroundColor = VIEW_BG_COLOR;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.textColor = [UIColor whiteColor];
	_label.text = kGSTitleCaption;
	[self.view addSubview:_label];
	
	//GameShareRecources.bundle/gs-backButton_normal
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = CGRectMake(5.0, 26.0, 39.0, 39.0);
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"gs-backButton_normal"] forState:UIControlStateNormal];
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"gs-backButton_highlighted"] forState:UIControlStateHighlighted];
	[_closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_closeButton];
	
	_skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_skipButton.frame = CGRectMake((self.view.bounds.size.width - 99.0) * 0.5, self.view.bounds.size.height - (26.0 + 10.0), 99.0, 26.0);
	[_skipButton.titleLabel setFont:NAV_LABEL_FONT];
	[_skipButton setTitleColor:NAV_NORMAL_COLOR forState:UIControlStateNormal];
	[_skipButton setTitleColor:NAV_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
	[_skipButton setTitle:kGSSkipButtonCaption forState:UIControlStateNormal];
	[_skipButton setTitle:kGSSkipButtonCaption forState:UIControlStateHighlighted];
	[_skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_skipButton];
	
	[_collectionView reloadData];
}


#pragma mark - Navigation
- (void)_goDismissViewController {
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
}

- (void)_goClose {
	NSLog(@"[:|:] [%@ - _goClose] [:|:]", self.class);
	
	if ([self.delegate respondsToSelector:@selector(gsCollectionViewDidClose:)])
		[self.delegate gsCollectionViewDidClose:self];
	
	[self _goDismissViewController];
}

- (void)_goSkip {
	NSLog(@"[:|:] [%@ - _goSkip] [:|:]", self.class);
	
	if ([self.delegate respondsToSelector:@selector(gsCollectionViewDidSkip:)])
		[self.delegate gsCollectionViewDidSkip:self];
	
	[self _goDismissViewController];
}

- (void)_goSelect {
	NSLog(@"[:|:] [%@ - _goSelect] [:|:]", self.class);
	
	NSDictionary *shareInfo = [self _shareInfoForMessengerShareType:_selectedMessengerType];
	NSLog(@"shareInfo:\n%@", shareInfo);
	
	if (_selectedMessengerType == GSMessengerShareTypeFBMessenger) {
		NSError *error;
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[shareInfo objectForKey:@"options"]
														   options:0
															 error:&error];
		
		if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
			_messengerURLHandler = [[FBSDKMessengerURLHandler alloc] init];
			_messengerURLHandler.delegate = self;
			
			FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
			options.metadata = [[NSString alloc] initWithData:jsonData
													 encoding:NSUTF8StringEncoding];
			options.contextOverride = [[FBSDKMessengerBroadcastContext alloc] init];
			
			[FBSDKMessengerSharer shareImage:[shareInfo objectForKey:@"share_image"]
								 withOptions:options];
		
		} else {
			[[[UIAlertView alloc] initWithTitle:@"FB Messenger Not Available!"
										message:@"Cannot open FB Messenger on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeKakaoTalk) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeKakaoTalk];
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			[KOAppCall openKakaoTalkAppLink:[shareInfo objectForKey:@"link_objs"]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"KakaoTalk Not Available!"
										message:@"Cannot open KakaoTalk right now"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeKik) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeKik] ;
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[schema objectForKey:@"protocol"] stringByAppendingFormat:[schema objectForKey:@"format"], @"www.gs.trydood.com/kikshare.php"]]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Kik Not Available!"
										message:@"Cannot open Kik on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeLine) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeLine];
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[schema objectForKey:@"protocol"] stringByAppendingFormat:[schema objectForKey:@"format"], [[shareInfo objectForKey:@"title"], [shareInfo objectForKey:@"link"] urlEncodedString]]]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"LINE Not Available!"
										message:@"Cannot open LINE on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeSMS) {
		if ([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.body = [NSString stringWithFormat:@"%@\n%@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
			messageComposeViewController.messageComposeDelegate = self;
			[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		
		} else {
			[[[UIAlertView alloc] initWithTitle:@"SMS Not Available!"
										message:@"SMS is not allowed for this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeWhatsApp) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeWhatsApp];
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[schema objectForKey:@"protocol"] stringByAppendingFormat:[schema objectForKey:@"format"], [[NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]] urlEncodedString]]]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"WhatsApp Not Available!"
										message:@"Cannot open WhatsApp on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeWeChat) {
		if ([WXApi isWXAppSupportApi]) {
//		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
			_selectedMessengerContent = @{@"title"		: [shareInfo objectForKey:@"title"],
										  @"body_text"	: [shareInfo objectForKey:@"body_text"],
										  @"image"		: [shareInfo objectForKey:@"image"],
										  @"url"		: [shareInfo objectForKey:@"link"]};
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"%@ %@ %@", [shareInfo objectForKey:@"title"], [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:@"Popup share details copied to clipboard"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView setTag:GSMessengerShareTypeWeChat];
			[alertView show];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"WeChat Not Available!"
										message:@"Cannot open WeChat on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeViber) {
		NSLog(@"schema:%@", [self _schemaForMessengerShareType:GSMessengerShareTypeViber]);
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeViber];
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			_selectedMessengerText = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = _selectedMessengerText;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:@"Popup share details copied to clipboard"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView setTag:GSMessengerShareTypeViber];
			[alertView show];
		
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Viber Not Available!"
										message:@"Cannot open Viber on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeHike) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeHike];
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]]) {
			_selectedMessengerText = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = _selectedMessengerText;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:@"Popup share details copied to clipboard"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView setTag:GSMessengerShareTypeHike];
			[alertView show];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Hike Not Available!"
										message:@"Cannot open Hike on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerShareTypeOTHER) {
		
	} else {
		shareInfo = @{};
	}
	
	if ([shareInfo count] > 0) {
		if ([self.delegate respondsToSelector:@selector(gsCollectionView:didSelectMessenger:)])
			[self.delegate gsCollectionView:self didSelectMessenger:_selectedMessengerVO];
	}
}

- (void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	NSLog(@"[:|:] [%@ - _goLongPress] [:|:]", self.class);
	
	if (lpGestureRecognizer.state != UIGestureRecognizerStateBegan)
		return;
	
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[lpGestureRecognizer locationInView:_collectionView]];
	
	if (indexPath != nil) {
		GSCollectionViewCell *viewCell = (GSCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
		_selectedMessengerVO = viewCell.messengerVO;
	}
}


#pragma mark - GSCollectionViewCell Delegates
- (void)collectionViewCell:(GSCollectionViewCell *)viewCell didSelectMessgenger:(GSMessengerVO *)vo {
	NSLog(@"[*:*] [%@ - collectionViewCell:didSelectMessgenger:%@])", self.class, vo.messengerName);
	
	_selectedMessengerType = viewCell.messengerType;
	_selectedMessengerVO = vo;
	[self _goSelect];
}


#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	//NSLog(@"[:|:] [%@ - numberOfSectionsInCollectionView] [:|:]", self.class);
	return (1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	//NSLog(@"[:|:] [%@ - collectionView:numberOfItemsInSection] [:|:]", self.class);
	return ([_selectedMessengers count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"[:|:] [%@ - collectionView:cellForItemAtIndexPath] [:|:]", self.class);
	
	GSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GSCollectionViewCell cellReuseIdentifier]
																		   forIndexPath:indexPath];
	
	GSMessengerVO *vo = (GSMessengerVO *)[_selectedMessengers objectAtIndex:indexPath.row];
	cell.messengerVO = vo;
	cell.messengerType = vo.messengerID;
	cell.delegate = self;
 
	return (cell);
}


#pragma mark - UICollectionView Delegates
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"[:|:] [%@ - collectionView:willDisplayCell:%@ forItemAtIndexPath:%@] [:|:]", self.class, cell, NSStringFromNSIndexPath(indexPath));
	
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125
								   delay:0.050
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
								  cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"[:|:] [%@ - collectionView:shouldHighlightItemAtIndexPath:%@] [:|:]", self.class, NSStringFromNSIndexPath(indexPath));
	return (NO);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"[:|:] [%@ - collectionView:shouldSelectItemAtIndexPath:%@] [:|:]", self.class, NSStringFromNSIndexPath(indexPath));
	return (NO);
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"[:|:] [%@ - collectionView:didSelectItemAtIndexPath:%@] [:|:]", self.class, NSStringFromNSIndexPath(indexPath));
//	
//	GSCollectionViewCell *viewCell = (GSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//	
//	_selectedMessengerType = viewCell.messengerType;
//	_selectedMessengerVO = viewCell.messengerVO;
//	[self _goSelect];
//}


#pragma mark - Messenger Delegates
#pragma mark - FBSDKMessengerURL Delegates
- (void)messengerURLHandler:(FBSDKMessengerURLHandler *)messengerURLHandler didHandleCancelWithContext:(FBSDKMessengerURLHandlerCancelContext *)context {
	NSLog(@"messengerURLHandler:didHandleOpenFromComposerWithContext:[%@]", context);
}

- (void)messengerURLHandler:(FBSDKMessengerURLHandler *)messengerURLHandler didHandleOpenFromComposerWithContext:(FBSDKMessengerURLHandlerOpenFromComposerContext *)context {
	NSLog(@"messengerURLHandler:didHandleOpenFromComposerWithContext:[%@]", context.metadata);
}

- (void)messengerURLHandler:(FBSDKMessengerURLHandler *)messengerURLHandler didHandleReplyWithContext:(FBSDKMessengerURLHandlerReplyContext *)context {
	NSLog(@"messengerURLHandler:didHandleReplyWithContext:[%@]", context.metadata);
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView:%d didDismissWithButtonIndex:%d", (int)alertView.tag, (int)buttonIndex);
	
	if (alertView.tag == GSMessengerShareTypeWeChat) {
		[WXApi registerApp:@"ID:wxad3790468c7ae7dd"
		   withDescription:[[NSBundle mainBundle] bundleIdentifier]];
		
		WXImageObject *imageObject = [WXImageObject object];
		imageObject.imageData = UIImageJPEGRepresentation([_selectedMessengerContent objectForKey:@"image"], 0.85);
		
		WXWebpageObject *webpageObject = [WXWebpageObject object];
		webpageObject.webpageUrl = [_selectedMessengerContent objectForKey:@"url"];
		
		WXMediaMessage *message = [WXMediaMessage message];
		message.title = [_selectedMessengerContent objectForKey:@"title"];
		message.description = [_selectedMessengerContent objectForKey:@"body_text"];
		[message setThumbImage:[_selectedMessengerContent objectForKey:@"image"]];
		message.mediaObject = webpageObject;
		
		SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
		req.text = [NSString stringWithFormat:@"%@ %@", [_selectedMessengerContent objectForKey:@"title"], [_selectedMessengerContent objectForKey:@"body_text"]];
		req.bText = NO;
		req.message = message;
		req.scene = WXSceneSession;
		[WXApi sendReq:req];
		
	} else if (alertView.tag == GSMessengerShareTypeHike) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeHike];
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"combsbhike://" stringByAppendingString:_selectedMessengerText]]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[schema objectForKey:@"protocol"]]];
		
	} else if (alertView.tag == GSMessengerShareTypeViber) {
		NSDictionary *schema = [self _schemaForMessengerShareType:GSMessengerShareTypeViber];
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"Viber://" stringByAppendingString:_selectedMessengerText]]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[schema objectForKey:@"protocol"] stringByAppendingFormat:[schema objectForKey:@"format"], [@" " urlEncodedString]]]];
	}
}

#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark - Helpers
- (GSMessengerVO *)_messengerVOForShareType:(GSMessengerShareType)messengerShareType {
	NSLog(@"[:|:] [%@ - _messengerVOForShareType:%d] [:|:]", self.class, (int)messengerShareType);
	
	__block GSMessengerVO *messengerVO = nil;
	[_allMessengers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSMessengerVO *vo = (GSMessengerVO *)obj;
		
		if (vo.messengerID == (int)messengerShareType) {
			messengerVO = vo;
			*stop = YES;
		}
	}];
	
	return (messengerVO);
}

- (NSDictionary *)_schemaForMessengerShareType:(GSMessengerShareType)messengerShareType {
	NSLog(@"[:|:] [%@ - _schemaForShareType:%d] [:|:]", self.class, (int)messengerShareType);
	
	GSMessengerVO *vo = [self _messengerVOForShareType:messengerShareType];
	
	__block NSDictionary *schema = nil;
	[_messengerSchemas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		
		if ([[dict objectForKey:@"name"] isEqualToString:vo.messengerName]) {
			schema = dict;
			*stop = YES;
		}
	}];
	
	return (schema);
}

- (NSDictionary *)_shareInfoForMessengerShareType:(GSMessengerShareType)messengerShareType {
	NSMutableDictionary *shareInfo = [NSMutableDictionary dictionary];
	
	NSLog(@"[:|:] [%@ - _shareInfoForMessengerType:%d] [:|:]", self.class, (int)messengerShareType);
	NSLog(@"_baseShareInfo:\n%@", _baseShareInfo);
	
	if (messengerShareType == GSMessengerShareTypeFBMessenger) {
		NSDictionary *fbShareInfo = [_baseShareInfo objectForKey:kFBMessengerKey];
		NSLog(@"fbShareInfo:\n%@", fbShareInfo);
		BOOL isOverride = (BOOL)[[fbShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:[UIImage imageNamed:([[fbShareInfo objectForKey:@"share_image"] length] > 0) ? [fbShareInfo objectForKey:@"share_image"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image"] : @""] forKey:@"share_image"];
		[shareInfo setObject:([[fbShareInfo objectForKey:@"options"] count] > 0) ? [fbShareInfo objectForKey:@"options"] : (!isOverride) ? [_baseShareInfo objectForKey:@"options"] : @{} forKey:@"options"];
	
	} else if (messengerShareType == GSMessengerShareTypeKakaoTalk) {
		NSDictionary *kakaoShareInfo = [_baseShareInfo objectForKey:kKakaoTalkKey];
		NSLog(@"kakaoShareInfo:\n%@", kakaoShareInfo);
		BOOL isOverride = (BOOL)[[kakaoShareInfo objectForKey:@"override"] intValue];
		
		NSMutableArray *linkObjs = [NSMutableArray array];
		NSString *title = ([[kakaoShareInfo objectForKey:@"title"] length] > 0) ? [kakaoShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"";
		UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:([[kakaoShareInfo objectForKey:@"image_url"] length] > 0) ? @"kakao_image" : (!isOverride) ? @"main_image_url" : nil]];
		NSString *url = ([_outboundURL length] == 0) ? ([[kakaoShareInfo objectForKey:@"outbound_url"] length] > 0) ? [kakaoShareInfo objectForKey:@"outbound_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"sub_image_url"] : @"" : _outboundURL;
		
		if ([title length] > 0) {
			[linkObjs addObject:[KakaoTalkLinkObject createLabel:title]];
		}
		
		if (image != nil) {
			[linkObjs addObject:[KakaoTalkLinkObject createImage:([[kakaoShareInfo objectForKey:@"image_url"] length] > 0) ? [kakaoShareInfo objectForKey:@"image_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image_url"] : @""
														   width:image.size.width
														  height:image.size.height]];
		}
		
		if ([url length] > 0) {
			[linkObjs addObject:[KakaoTalkLinkObject createWebButton:([[kakaoShareInfo objectForKey:@"button_text"] length] > 0) ? [kakaoShareInfo objectForKey:@"button_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @""
																 url:url]];
		}
		
		[shareInfo setObject:[linkObjs copy] forKey:@"link_objs"];
		
//		UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"main_image_url"]];
//		shareInfo = @{@"link_objs"	: @[[KakaoTalkLinkObject createLabel:[_baseShareInfo objectForKey:@"title"]],
//										[KakaoTalkLinkObject createImage:[_baseShareInfo objectForKey:@"main_image_url"]
//																   width:image.size.width
//																  height:image.size.height],
//										[KakaoTalkLinkObject createWebButton:[_baseShareInfo objectForKey:@"subtitle"]
//																		 url:[_baseShareInfo objectForKey:@"sub_image_url"]]]};

	} else if (messengerShareType == GSMessengerShareTypeKik) {
		NSDictionary *kikShareInfo = [_baseShareInfo objectForKey:kKikKey];
		NSLog(@"kikShareInfo:\n%@", kikShareInfo);
		BOOL isOverride = (BOOL)[[kikShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[kikShareInfo objectForKey:@"title"] length] > 0) ? [kikShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"" forKey:@"title"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"subtitle"] length] > 0) ? [kikShareInfo objectForKey:@"subtitle"] : (!isOverride) ? [_baseShareInfo objectForKey:@"subtitle"] : @"" forKey:@"subtitle"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"icon_url"] length] > 0) ? [kikShareInfo objectForKey:@"icon_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"sub_image_url"] : @"" forKey:@"icon_url"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"image_url"] length] > 0) ? [kikShareInfo objectForKey:@"image_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image_url"] : @"" forKey:@"image_url"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"body_text"] length] > 0) ? [kikShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[kikShareInfo objectForKey:@"outbound_url"] length] > 0) ? [kikShareInfo objectForKey:@"outbound_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"outbound_url"];
		
	} else if (messengerShareType == GSMessengerShareTypeLine) {
		NSDictionary *lineShareInfo = [_baseShareInfo objectForKey:kLineKey];
		NSLog(@"lineShareInfo:\n%@", lineShareInfo);
		BOOL isOverride = (BOOL)[[lineShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[lineShareInfo objectForKey:@"body_text"] length] > 0) ? [lineShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[lineShareInfo objectForKey:@"link"] length] > 0) ? [lineShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeSMS) {
		NSDictionary *smsShareInfo = [_baseShareInfo objectForKey:kSMSKey];
		NSLog(@"smsShareInfo:\n%@", smsShareInfo);
		BOOL isOverride = (BOOL)[[smsShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[smsShareInfo objectForKey:@"body_text"] length] > 0) ? [smsShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[smsShareInfo objectForKey:@"link"] length] > 0) ? [smsShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeWhatsApp) {
		NSDictionary *whatsAppShareInfo = [_baseShareInfo objectForKey:kWhatsAppKey];
		NSLog(@"whatsAppShareInfo:\n%@", whatsAppShareInfo);
		BOOL isOverride = (BOOL)[[whatsAppShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[whatsAppShareInfo objectForKey:@"body_text"] length] > 0) ? [whatsAppShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[whatsAppShareInfo objectForKey:@"link"] length] > 0) ? [whatsAppShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"": _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeWeChat) {
		NSDictionary *weChatShareInfo = [_baseShareInfo objectForKey:kWeChatKey];
		NSLog(@"weChatShareInfo:\n%@", weChatShareInfo);
		BOOL isOverride = (BOOL)[[weChatShareInfo objectForKey:@"override"] intValue];
		[shareInfo setObject:([[weChatShareInfo objectForKey:@"title"] length] > 0) ? [weChatShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"" forKey:@"title"];
		[shareInfo setObject:([[weChatShareInfo objectForKey:@"body_text"] length] > 0) ? [weChatShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:[UIImage imageNamed:([[weChatShareInfo objectForKey:@"image"] length] > 0) ? [weChatShareInfo objectForKey:@"image"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image"] : nil] forKey:@"image"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[weChatShareInfo objectForKey:@"link"] length] > 0) ? [weChatShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeHike) {
		NSDictionary *hikeShareInfo = [_baseShareInfo objectForKey:kHikeKey];
		NSLog(@"hikeShareInfo:\n%@", hikeShareInfo);
		BOOL isOverride = (BOOL)[[hikeShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[hikeShareInfo objectForKey:@"body_text"] length] > 0) ? [hikeShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[hikeShareInfo objectForKey:@"link"] length] > 0) ? [hikeShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeViber) {
		NSDictionary *viberShareInfo = [_baseShareInfo objectForKey:kOTHERKey];
		NSLog(@"viberShareInfo:\n%@", viberShareInfo);
		BOOL isOverride = (BOOL)[[viberShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[viberShareInfo objectForKey:@"body_text"] length] > 0) ? [viberShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[viberShareInfo objectForKey:@"link"] length] > 0) ? [viberShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeOTHER) {
		NSDictionary *otherShareInfo = [_baseShareInfo objectForKey:kOTHERKey];
		NSLog(@"otherShareInfo:\n%@", otherShareInfo);
		BOOL isOverride = (BOOL)[[otherShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[otherShareInfo objectForKey:@"body_text"] length] > 0) ? [otherShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? ([[otherShareInfo objectForKey:@"link"] length] > 0) ? [otherShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" : _outboundURL forKey:@"link"];
		
	} else {
		[shareInfo setObject:[_baseShareInfo objectForKey:@"body_text"] forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] == 0) ? [_baseShareInfo objectForKey:@"outbound_url"] :_outboundURL forKey:@"link"];
	}
	
	return (shareInfo);
}

- (void)_writeWebImageFromURL:(NSString *)url toUserDefaultsKey:(NSString *)key {
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
																			  imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
																				  image = (image != nil) ? image : [UIImage imageNamed:key];
																				  [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:key];
																				  [[NSUserDefaults standardUserDefaults] synchronize];
																				  
																			  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
																				  [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation([UIImage imageNamed:key]) forKey:key];
																				  [[NSUserDefaults standardUserDefaults] synchronize];
																			  }];
	
	[operation start];
}


@end
