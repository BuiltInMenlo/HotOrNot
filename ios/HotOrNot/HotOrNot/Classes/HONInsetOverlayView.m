//
//  HONInsetOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 08/01/2014 @ 14:30 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONInsetOverlayView.h"
#import "HONImageLoadingView.h"

@interface HONInsetOverlayView ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@end

@implementation HONInsetOverlayView
@synthesize delegate = _delegate;

- (id)initAsType:(HONInsetOverlayViewType)insetType {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		NSDictionary *contents = [[[NSUserDefaults standardUserDefaults] objectForKey:@"inset_modals"] objectForKey:(insetType == HONInsetOverlayViewTypeAppReview) ? @"review" : (insetType == HONInsetOverlayViewTypeSuggestions) ? @"contacts" : @"unlock"];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dimBackground"]];
		bgImageView.frame = [[UIScreen mainScreen] bounds];
		[self addSubview:bgImageView];
		
		_framingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([[UIScreen mainScreen] bounds].size.height - 480.0) * 0.5, 320.0, 480.0)];
		_framingImageView.userInteractionEnabled = YES;
		[self addSubview:_framingImageView];
		
		void (^framingSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_framingImageView.image = image;
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
		};

		void (^framingFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
		};
		
		NSLog(@"BG:[%@] (%@)", [[contents objectForKey:@"bg"] stringByReplacingOccurrencesOfString:@"png" withString:[[[NSLocale preferredLanguages] firstObject] stringByAppendingString:@".png"]], [[NSLocale preferredLanguages] firstObject]);
		[_framingImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[contents objectForKey:@"bg"] stringByReplacingOccurrencesOfString:@"png" withString:[[[NSLocale preferredLanguages] firstObject] stringByAppendingString:@".png"]]]
																   cachePolicy:kURLRequestCachePolicy
															   timeoutInterval:[HONAppDelegate timeoutInterval]]
								 placeholderImage:[UIImage imageNamed:(insetType == HONInsetOverlayViewTypeAppReview || insetType == HONInsetOverlayViewTypeSuggestions) ? @"inset1BG" : @"inset2BG"]
										  success:framingSuccessBlock
										  failure:framingFailureBlock];
		
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(255.0, 14.0, 44.0, 44);
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateHighlighted];
		[_framingImageView addSubview:closeButton];
		
		_acknowledgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_acknowledgeButton.frame = CGRectMake(20.0, 416.0, 280.0, 50.0);
		[_framingImageView addSubview:_acknowledgeButton];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_framingImageView asLargeLoader:NO];
		[_framingImageView addSubview:_imageLoadingView];
		
		if (insetType == HONInsetOverlayViewTypeAppReview) {
			NSString *contentURL = [[contents objectForKey:@"img"] stringByReplacingOccurrencesOfString:@"png" withString:[[[NSLocale preferredLanguages] firstObject] stringByAppendingString:@".png"]];
			NSLog(@"CONTENT:[%@] (%@)", contentURL, [[NSLocale preferredLanguages] firstObject]);
			
			UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 61.0, 286.0, 350.0)];
			[_framingImageView addSubview:contentImageView];
			
			void (^contentSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				contentImageView.image = image;
			};
			
			void (^contentFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {};
			
			
			[contentImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:contentURL]
																	   cachePolicy:kURLRequestCachePolicy
																   timeoutInterval:[HONAppDelegate timeoutInterval]]
									 placeholderImage:nil
											 success:contentSuccessBlock
											  failure:contentFailureBlock];
			
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"tapToReview_nonActive"] forState:UIControlStateNormal];
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"tapToReview_Active"] forState:UIControlStateHighlighted];
			[_acknowledgeButton addTarget:self action:@selector(_goReview) forControlEvents:UIControlEventTouchDown];
		
		} else if (insetType == HONInsetOverlayViewTypeUnlock) {
			NSArray *contentRows = [contents objectForKey:@"rows"];
			UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(18.0, 146.0, 285.0, 265.0)];
			
			scrollView.contentSize = CGSizeMake(285.0, 175.0 * [contentRows count]);
			scrollView.showsVerticalScrollIndicator = NO;
			[_framingImageView addSubview:scrollView];
			
			for (int i=0; i<[contentRows count]; i++) {
				NSString *contentURL = [[contentRows objectAtIndex:i] stringByReplacingOccurrencesOfString:@"png" withString:[[[NSLocale preferredLanguages] firstObject] stringByAppendingString:@".png"]];
				NSLog(@"CONTENT:[%@] (%@)", contentURL, [[NSLocale preferredLanguages] firstObject]);
				
				UIImageView *rowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, i * 175.0, 287.0, 175.0)];
				rowImageView.image = [UIImage imageNamed:@"largeRowOfferBackground"];
				[scrollView addSubview:rowImageView];
				
				UIImageView *stickerImageView = [[UIImageView alloc] initWithFrame:rowImageView.frame];
				[scrollView addSubview:stickerImageView];
				
				void (^contentSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					stickerImageView.image = image;
				};
				
				void (^contentFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {};
				
				[stickerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:contentURL]
																		  cachePolicy:kURLRequestCachePolicy
																	  timeoutInterval:[HONAppDelegate timeoutInterval]]
										placeholderImage:nil
												 success:contentSuccessBlock
												 failure:contentFailureBlock];
			}
			
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
			[_acknowledgeButton addTarget:self action:@selector(_goUnlock) forControlEvents:UIControlEventTouchDown];
		
		} else if (insetType == HONInsetOverlayViewTypeSuggestions) {
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"accessContacts_nonActive"] forState:UIControlStateNormal];
			[_acknowledgeButton setBackgroundImage:[UIImage imageNamed:@"accessContacts_Active"] forState:UIControlStateHighlighted];
			[_acknowledgeButton addTarget:self action:@selector(_goSuggestions) forControlEvents:UIControlEventTouchDown];
		}
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
	if ([self.delegate respondsToSelector:@selector(insetOverlayViewDidClose:)])
		[self.delegate insetOverlayViewDidClose:self];
}

- (void)_goReview {
	if ([self.delegate respondsToSelector:@selector(insetOverlayViewDidReview:)])
		[self.delegate insetOverlayViewDidReview:self];
}

- (void)_goSuggestions {
	if ([self.delegate respondsToSelector:@selector(insetOverlayViewDidAccessContents:)])
		[self.delegate insetOverlayViewDidAccessContents:self];
}

- (void)_goUnlock {
	if ([self.delegate respondsToSelector:@selector(insetOverlayViewDidUnlock:)])
		[self.delegate insetOverlayViewDidUnlock:self];
}

@end
