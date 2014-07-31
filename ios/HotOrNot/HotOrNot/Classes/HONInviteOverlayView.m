//
//  HONInviteOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//
#import "HONImageLoadingView.h"
#import "HONInviteOverlayView.h"
#import "UIImageView+AFNetworking.h"

@interface HONInviteOverlayView ()
@property (nonatomic, strong) UIView *holderView;
@end

@implementation HONInviteOverlayView
@synthesize delegate = _delegate;

- (id)initWithOverlayType:(Overlaytype)type  {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		
		self.alpha = 0.0;
        
        UIImageView *dimBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dimBackground"]];
        dimBackground.frame = [[UIScreen mainScreen] bounds];
		[self addSubview:dimBackground];
        UIImageView *frameModal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modalUnlockBackground"]];
        frameModal.frame = CGRectOffset(frameModal.frame, 0, ([[UIScreen mainScreen] bounds].size.height - 462)/2);
        frameModal.userInteractionEnabled = YES;
		[self addSubview:frameModal];
        
        UIScrollView *startScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(18,146,285,265)];
        startScrollView.contentSize = CGSizeMake(285,500);
        //startScrollView.backgroundColor = [UIColor redColor];
        [frameModal addSubview:startScrollView];
        
        UIImageView *row = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,287,175)];
        row.image = [UIImage imageNamed:@"largeRowOfferBackground"];
		[startScrollView addSubview:row];
        UIImageView *row2 = [[UIImageView alloc] initWithFrame:CGRectMake(0,175,287,175)];
        row2.image = [UIImage imageNamed:@"largeRowOfferBackground"];
		[startScrollView addSubview:row2];
        UIImageView *row3 = [[UIImageView alloc] initWithFrame:CGRectMake(0,350,287,175)];
        row3.image = [UIImage imageNamed:@"largeRowOfferBackground"];
		[startScrollView addSubview:row3];
        startScrollView.showsVerticalScrollIndicator = NO;
        
        UIImageView *stickerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,287,175)];
        stickerImage.image = [UIImage imageNamed:@"stickerFromServer_001"];
		[startScrollView addSubview:stickerImage];
        UIImageView *stickerImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0,175,287,175)];
        stickerImage2.image = [UIImage imageNamed:@"stickerFromServer_001"];
		[startScrollView addSubview:stickerImage2];
        UIImageView *stickerImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(0,350,287,175)];
        stickerImage3.image = [UIImage imageNamed:@"stickerFromServer_001"];
		[startScrollView addSubview:stickerImage3];
        
      
        
        
//		HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self asLargeLoader:NO];
//		[self addSubview:imageLoadingView];
//		
//		_holderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//		_holderView.alpha = 0.0;
//		[self addSubview:_holderView];
//		
//		UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//		[_holderView addSubview:imageView];
//		
//		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			imageView.image = image;
//			[UIView animateWithDuration:0.25 animations:^(void) {
//				_holderView.alpha = 1.0;
//			} completion:^(BOOL finished) {
//				[imageLoadingView stopAnimating];
//			}];
//		};
		
//		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[@"https://s3.amazonaws.com/hotornot-banners/" stringByAppendingString:imageURL] stringByAppendingFormat:@"%@@2x.png",[[HONDeviceIntrinsics sharedInstance] isRetina4Inch]? @"-568h" : @""]]
//														   cachePolicy:kURLRequestCachePolicy
//													   timeoutInterval:[HONAppDelegate timeoutInterval]]
//						 placeholderImage:nil
//								  success:imageSuccessBlock
//								  failure:nil];
//		
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(255.0, 68.0, 44, 44);
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateHighlighted];
		[self addSubview:closeButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(300.0, 100.0, 88.0, 88.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchDown];
		//[self addSubview:skipButton];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(20.0, 468.0, 560/2, 50.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"invite2Unlock_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"invite2Unlock_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchDown];
		[self addSubview:inviteButton];
	}
	
	return (self);

}

#pragma mark - Public APIs
- (void)introWithCompletion:(void (^)(BOOL finished))completion {
	self.alpha = 0.0;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		self.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		if (completion)
			completion(finished);
	}];
}

- (void)outroWithCompletion:(void (^)(BOOL finished))completion {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		for (UIView *view in self.subviews) {
			[view removeFromSuperview];
		}
		
		if (completion)
			completion(finished);
	}];
}


#pragma mark - Navigation
- (void)_goClose {
	if ([self.delegate respondsToSelector:@selector(inviteOverlayViewClose:)])
		[self.delegate inviteOverlayViewClose:self];
}

- (void)_goInvite {
	if ([self.delegate respondsToSelector:@selector(inviteOverlayViewInvite:)])
		[self.delegate inviteOverlayViewInvite:self];
}

- (void)_goSkip {
	if ([self.delegate respondsToSelector:@selector(inviteOverlayViewSkip:)])
		[self.delegate inviteOverlayViewSkip:self];
}


@end
