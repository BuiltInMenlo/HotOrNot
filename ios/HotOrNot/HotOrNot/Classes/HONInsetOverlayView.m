//
//  HONInsetOverlayView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 08/01/2014 @ 14:30 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+FormattedText.h"
#import "UIImageView+AFNetworking.h"

#import "HONInsetOverlayView.h"
#import "HONImageLoadingView.h"

@interface HONInsetOverlayView ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) NSArray *clubs;
@end

@implementation HONInsetOverlayView
@synthesize delegate = _delegate;

- (id)initAsType:(HONInsetOverlayViewType)insetType {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		NSDictionary *contents = [[[NSUserDefaults standardUserDefaults] objectForKey:@"inset_modals"] objectForKey:(insetType == HONInsetOverlayViewTypeAppReview) ? @"review" : (insetType == HONInsetOverlayViewTypeSuggestions) ? @"contacts" : @"unlock"];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dimBackground"]];
		bgImageView.frame = [[UIScreen mainScreen] bounds];
		[self addSubview:bgImageView];
		
		_framingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([[UIScreen mainScreen] bounds].size.height - 460.0) * 0.5, 320.0, 480.0)];
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
		closeButton.frame = CGRectMake(257.0, 15.0, 44.0, 44.0);
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"modalCloseButton"] forState:UIControlStateHighlighted];
		[_framingImageView addSubview:closeButton];
		
		_acknowledgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_acknowledgeButton.frame = CGRectMake(20.0, 415.0, 280.0, 50.0);
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
			scrollView.alwaysBounceVertical = YES;
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
			UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(18.0, 64.0, 285.0, 347.0)];
			[scrollView setContentInset:UIEdgeInsetsMake(-3.0, -18.0, 0.0, 0.0)];
			scrollView.showsVerticalScrollIndicator = NO;
			scrollView.alwaysBounceVertical = YES;
			[_framingImageView addSubview:scrollView];
			
			
			UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallRowOfferBackground"]];
			bgImageView.userInteractionEnabled = YES;
			[scrollView addSubview:bgImageView];
			
			NSString *clubName = [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""];
			NSString *titleCaption = [clubName stringByAppendingString:NSLocalizedString(@"title_copyURL", @" - copy your url")];
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(31.0, 14.0, 250.0, 16.0)];
			titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
			titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{}];
			[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[titleCaption rangeOfString:clubName]];
			[titleLabel setTextColor:[UIColor blackColor] range:[titleCaption rangeOfString:clubName]];
			[bgImageView addSubview:titleLabel];
			
			UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 33.0, 250.0, 16.0)];
			subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
			subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			subtitleLabel.text = [NSString stringWithFormat:@"joinselfie.club/%@/%@", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""]];
			[bgImageView addSubview:subtitleLabel];
			
			UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
			createClubButton.frame = bgImageView.frame;
			[createClubButton addTarget:self action:@selector(_goPersonalClub) forControlEvents:UIControlEventTouchUpInside];
			[bgImageView addSubview:createClubButton];
			
			_clubs = nil;
			_clubs	= (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:@"Locked Club"]) ? [[NSArray arrayWithObject:[HONUserClubVO clubWithDictionary:[[HONClubAssistant sharedInstance] orthodoxThresholdClubDictionary]]] arrayByAddingObjectsFromArray:[[HONClubAssistant sharedInstance] suggestedClubs]] : [[HONClubAssistant sharedInstance] suggestedClubs];
			
			scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, kOrthodoxTableCellHeight * ([_clubs count] + 1));
			
			[_clubs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				HONUserClubVO *vo = (HONUserClubVO *)obj;
				
				UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallRowOfferBackground"]];
				bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, kOrthodoxTableCellHeight + (idx * kOrthodoxTableCellHeight));
				bgImageView.userInteractionEnabled = YES;
				[scrollView addSubview:bgImageView];
				
				NSString *titleCaption = [vo.clubName stringByAppendingString:NSLocalizedString(@"title_joinNow", @" - Join Now!")]; //@" - Join Now!"
				UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(31.0, 14.0, 238.0, 16.0)];
				titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
				titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
				titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{}];
				[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[titleCaption rangeOfString:vo.clubName]];
				[titleLabel setTextColor:[UIColor blackColor] range:[titleCaption rangeOfString:vo.clubName]];
				[bgImageView addSubview:titleLabel];
				
				UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 33.0, 180.0, 16.0)];
				subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
				subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
				[bgImageView addSubview:subtitleLabel];
				
				NSString *subtitleCaption = vo.ownerName;
				if ([vo.activeMembers count] > 0) {
					subtitleCaption = [subtitleCaption stringByAppendingString:@", "];
					int cnt = 0;
					for (HONTrivialUserVO *userVO in vo.activeMembers) {
						NSString *caption = ([vo.activeMembers count] - cnt > 1) ? [subtitleCaption stringByAppendingFormat:@"%@, & %d more", userVO.username, ([vo.activeMembers count] - cnt)] : [subtitleCaption stringByAppendingString:userVO.username];
						CGSize size = [caption boundingRectWithSize:subtitleLabel.frame.size
															options:NSStringDrawingTruncatesLastVisibleLine
														 attributes:@{NSFontAttributeName:subtitleLabel.font}
															context:nil].size;
						NSLog(@"SIZE:[%@](%@)", NSStringFromCGSize(size), caption);
						if (size.width >= subtitleLabel.frame.size.width)
							break;
						
						subtitleCaption = [subtitleCaption stringByAppendingFormat:@"%@, ", userVO.username];
						cnt++;
					}
					
					subtitleCaption = [subtitleCaption substringToIndex:[subtitleCaption length] - 2];
					int remaining = [vo.activeMembers count] - cnt;
					
					if (remaining > 0)
						subtitleCaption = [subtitleCaption stringByAppendingFormat:@", & %d more", remaining];
				}
				
				subtitleLabel.text = subtitleCaption;
				
				UIButton *createClubButton = [UIButton buttonWithType:UIButtonTypeCustom];
				createClubButton.frame = CGRectMake(237.0, 10.0, 64.0, 44.0);
				[createClubButton setTag:idx];
				[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_nonActive"] forState:UIControlStateNormal];
				[createClubButton setBackgroundImage:[UIImage imageNamed:@"plusClubButton_Active"] forState:UIControlStateHighlighted];
				[createClubButton addTarget:self action:(vo.clubEnrollmentType == HONClubEnrollmentTypeSuggested) ? @selector(_goCreateClub:) : @selector(_goThresholdClub:) forControlEvents:UIControlEventTouchUpInside];
				[bgImageView addSubview:createClubButton];
				
			}];
			
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

- (void)_goPersonalClub {
	if ([self.delegate respondsToSelector:@selector(insetOverlayViewCopyPersonalClub:)])
		[self.delegate insetOverlayViewCopyPersonalClub:self];
}

- (void)_goCreateClub:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	if ([self.delegate respondsToSelector:@selector(insetOverlayView:createSuggestedClub:)])
		[self.delegate insetOverlayView:self createSuggestedClub:[_clubs objectAtIndex:button.tag]];
}

- (void)_goThresholdClub:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	if ([self.delegate respondsToSelector:@selector(insetOverlayView:thresholdClub:)])
		[self.delegate insetOverlayView:self thresholdClub:[_clubs objectAtIndex:button.tag]];
}

@end
