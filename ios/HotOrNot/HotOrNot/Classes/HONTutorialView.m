//
//  HONTutorialView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//
#import "HONImageLoadingView.h"
#import "HONTutorialView.h"
#import "UIImageView+AFNetworking.h"

@interface HONTutorialView ()
@property (nonatomic, strong) UIView *holderView;
@end

@implementation HONTutorialView
@synthesize delegate = _delegate;

- (id)initWithContentImage:(NSString *)imageURL {
    if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		
		self.alpha = 0.0;
        HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self asLargeLoader:NO];
        [self addSubview:imageLoadingView];
		
		_holderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_holderView.alpha = 0.0;
		[self addSubview:_holderView];
		
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		[_holderView addSubview:imageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            imageView.image = image;
            [UIView animateWithDuration:0.25 animations:^(void) {
                _holderView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [imageLoadingView stopAnimating];
            }];
        };
		
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[@"https://s3.amazonaws.com/hotornot-banners/" stringByAppendingString:imageURL] stringByAppendingFormat:@"%@@2x.png",[[HONDeviceIntrinsics sharedInstance] isRetina4Inch]? @"-568h" : @""]]
                                                           cachePolicy:kURLRequestCachePolicy
                                                       timeoutInterval:[HONAppDelegate timeoutInterval]]
                         placeholderImage:nil
                                  success:imageSuccessBlock
                                  failure:nil];
		
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(275.0, 60.0, 44, 44);
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_Active"] forState:UIControlStateHighlighted];
		[_holderView addSubview:closeButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(128.0, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 413.0 : 341.0, 64.0, 24.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"tutorial_skipButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"tutorial_skipButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchDown];
		[_holderView addSubview:skipButton];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(0.0, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 443.0 : 366.0, 320.0, 51.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"tutorial_inviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"tutorial_inviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchDown];
		[_holderView addSubview:inviteButton];
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
	if ([self.delegate respondsToSelector:@selector(tutorialViewClose:)])
		[self.delegate tutorialViewClose:self];
}

- (void)_goInvite {
	if ([self.delegate respondsToSelector:@selector(tutorialViewInvite:)])
		[self.delegate tutorialViewInvite:self];
}

- (void)_goSkip {
	if ([self.delegate respondsToSelector:@selector(tutorialViewClose:)])
		[self.delegate tutorialViewClose:self];
}


@end
