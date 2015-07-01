//
//  GSCollectionViewController.m
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

#import "UILabel+BuiltInMenlo.h"
#import "UIView+BuiltInMenlo.h"

#import "GSCollectionViewController.h"
#import "GSCollectionViewFlowLayout.h"
#import "GSCollectionViewCell.h"

#define VIEW_BG_COLOR			[UIColor colorWithRed:0.133 green:0.875 blue:0.706 alpha:1.00]
#define WIDGET_COLOR			[UIColor colorWithRed:0.110 green:0.608 blue:0.490 alpha:1.00]
#define NAV_NORMAL_COLOR		[UIColor colorWithRed:0.110 green:0.608 blue:0.490 alpha:1.00]
#define NAV_HIGHLIGHTED_COLOR	[UIColor colorWithRed:0.075 green:0.420 blue:0.337 alpha:1.00]

#define NAV_LABEL_FONT			[UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define TITLE_LABEL_FONT		[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]

const CGSize kGSCollectionViewSize = {48.0, 48.0};

@interface GSCollectionViewController () <FBSDKMessengerURLHandlerDelegate, GSCollectionViewCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, strong) NSDictionary *baseShareInfo;
@property (nonatomic, strong) NSMutableArray *allMessengers;
@property (nonatomic, strong) NSMutableArray *selectedMessengers;
@property (nonatomic, strong) GSMessengerVO *selectedMessengerVO;
@property (nonatomic) GSMessengerType selectedMessengerType;

@property (nonatomic, strong) FBSDKMessengerURLHandler *messengerURLHandler;

@end

@implementation GSCollectionViewController
@synthesize delegate = _delegate;
@synthesize metaInfo;

static NSString * const kGSTitleCaption = @"Select a messenger";
static NSString * const kGSSkipButtonCaption = @"Skip";

+ (CGPoint)collectionViewDimension {
	return (CGPointMake(3, 3));
}

+ (NSArray *)supportedTypes {
	return (@[@(GSMessengerTypeFBMessenger), @(GSMessengerTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerTypeSMS), @(GSMessengerTypeWhatsApp), @(GSMessengerTypeWeChat), @(GSMessengerTypeHike), @(GSMessengerTypeOTHER)]);
}


- (id)init {
	NSLog(@"[:|:] [%@ - init] [:|:]", self.class);
	
	if ((self = [super init])) {
		_allMessengers = [NSMutableArray array];
		_selectedMessengers = [NSMutableArray array];
		
		
		[[NSArray arrayWithContentsOfFile:[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GameShareRecources" ofType:@"bundle"]] pathForResource:@"GSMessengers" ofType:@"plist"]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[_allMessengers addObject:[GSMessengerVO messengerWithDictionary:(NSDictionary *)obj]];
		}];
		
		/*
		 line://msg/text/Hi!%20Check%20out%20Skout%20http://taps.io/getSkout
		 whatsapp://send?text=Hi!%20Check%20out%20Skout%20http://taps.io/trySkout
		 sms://body=Hi!%20Check%20out%20Skout%20http://taps.io/installSkout
		*/
		
		_baseShareInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GSMessengerShareInfo"
																									ofType:@"plist"]];
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
			GSMessengerType messengerType = (GSMessengerType)[(NSNumber *)obj intValue];
			if ([[GSCollectionViewController supportedTypes] containsObject:@(messengerType)])
				[_selectedMessengers addObject:[self _messengerVOForType:messengerType]];
		}];
	}
	
	return (self);
}

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

- (void)didReceiveMemoryWarning {
	NSLog(@"[:|:] [%@ - didReceiveMemoryWarning] [:|:]", self.class);
	
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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
	_closeButton.frame = CGRectMake(10.0, 16.0, 99.0, 46.0);
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
	[self dismissViewControllerAnimated:YES completion:^(void) {
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
	
	NSDictionary *shareInfo = [self _shareInfoForMessengerType:_selectedMessengerType];
	NSLog(@"shareInfo:\n%@", shareInfo);
	
	if (_selectedMessengerType == GSMessengerTypeFBMessenger) {
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
		
	} else if (_selectedMessengerType == GSMessengerTypeKakaoTalk) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"kakaotalk://"]]) {
			[KOAppCall openKakaoTalkAppLink:[shareInfo objectForKey:@"link_objs"]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"KakaoTalk Not Available!"
										message:@"Cannot open KakaoTalk right now"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerTypeKik) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"card://"]]) {
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Kik Not Available!"
										message:@"Cannot open Kik on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerTypeLine) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/text/%@\n%@", [shareInfo objectForKey:@"title"], [shareInfo objectForKey:@"link"]]]];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"LINE Not Available!"
										message:@"Cannot open LINE on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerTypeSMS) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]]) {
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"SMS Not Available!"
										message:@"SMS is not allowed for this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerTypeWhatsApp) {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]]) {
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"WhatsApp Not Available!"
										message:@"Cannot open WhatsApp on this device"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (_selectedMessengerType == GSMessengerTypeWeChat) {
		
	} else if (_selectedMessengerType == GSMessengerTypeHike) {
		
	} else if (_selectedMessengerType == GSMessengerTypeOTHER) {
		
	} else {
	}
	
	if ([self.delegate respondsToSelector:@selector(gsCollectionView:didSelectMessenger:)])
		[self.delegate gsCollectionView:self didSelectMessenger:_selectedMessengerVO];
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


#pragma mark - <UICollectionViewDataSource>
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


#pragma mark - <UICollectionViewDelegate>
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
	return (YES);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"[:|:] [%@ - collectionView:didSelectItemAtIndexPath:%@] [:|:]", self.class, NSStringFromNSIndexPath(indexPath));
	
	GSCollectionViewCell *viewCell = (GSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	
	_selectedMessengerType = viewCell.messengerType;
	_selectedMessengerVO = viewCell.messengerVO;
	[self _goSelect];
}


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


#pragma mark - KakaoTalk
#pragma mark - Kik
#pragma mark - Line
#pragma mark - SMS
#pragma mark - WhatsApp
#pragma mark - WeChat
#pragma mark - Hike
#pragma mark - Other




#pragma mark -
#pragma mark - Helpers
- (GSMessengerVO *)_messengerVOForType:(GSMessengerType)messengerType {
	NSLog(@"[:|:] [%@ - _messengerVOForType:%d] [:|:]", self.class, (int)messengerType);
	
	__block GSMessengerVO *messengerVO = nil;
	[_allMessengers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GSMessengerVO *vo = (GSMessengerVO *)obj;
		
		if (vo.messengerID == (int)messengerType) {
			messengerVO = vo;
			*stop = YES;
		}
	}];
	
	return (messengerVO);
}

- (NSDictionary *)_shareInfoForMessengerType:(GSMessengerType)messengerType {
	NSDictionary *shareInfo;
	
	NSLog(@"[:|:] [%@ - _shareInfoForMessengerType:%d] [:|:]", self.class, (int)messengerType);
//	NSLog(@"_baseShareInfo:\n%@", _baseShareInfo);
	
	if (messengerType == GSMessengerTypeFBMessenger) {
		shareInfo = @{@"share_image"	: [UIImage imageNamed:[_baseShareInfo objectForKey:@"main_image"]],
					  @"options"		: [_baseShareInfo objectForKey:@"meta"]};
	
	} else if (messengerType == GSMessengerTypeKakaoTalk) {
		UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"main_image_url"]];
		
		NSLog(@"title:[%@]", [_baseShareInfo objectForKey:@"title"]);
		NSLog(@"subtitle:[%@]", [_baseShareInfo objectForKey:@"subtitle"]);
		NSLog(@"main_image_url:[%@] - %@", [_baseShareInfo objectForKey:@"main_image_url"], NSStringFromCGSize(image.size));
		NSLog(@"outbound_url:[%@]", [_baseShareInfo objectForKey:@"outbound_url"]);
		
		
		shareInfo = @{@"link_objs"	: @[[KakaoTalkLinkObject createLabel:[_baseShareInfo objectForKey:@"title"]],
										[KakaoTalkLinkObject createImage:[_baseShareInfo objectForKey:@"main_image_url"]
																   width:image.size.width
																  height:image.size.height],
										[KakaoTalkLinkObject createWebButton:[_baseShareInfo objectForKey:@"subtitle"]
																		 url:[_baseShareInfo objectForKey:@"sub_image_url"]]]};

	} else if (messengerType == GSMessengerTypeKik) {
		shareInfo = @{};
		
	} else if (messengerType == GSMessengerTypeLine) {
		shareInfo = @{@"title"	: [_baseShareInfo objectForKey:@"title"],
					  @"link"	: [_baseShareInfo objectForKey:@"outbound_url"]};
		
	} else if (messengerType == GSMessengerTypeSMS) {
		shareInfo = @{};
		
	} else if (messengerType == GSMessengerTypeWhatsApp) {
		shareInfo = @{};
		
	} else if (messengerType == GSMessengerTypeWeChat) {
		shareInfo = @{};
		
	} else if (messengerType == GSMessengerTypeHike) {
		shareInfo = @{};
		
	} else if (messengerType == GSMessengerTypeOTHER) {
		shareInfo = @{};
		
	} else {
		shareInfo = @{};
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
