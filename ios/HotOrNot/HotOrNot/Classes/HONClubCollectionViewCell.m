//
//  HONClubCollectionViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONClubCollectionViewCell.h"
#import "HONImageLoadingView.h"


@interface HONClubCollectionViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *badgeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation HONClubCollectionViewCell
@synthesize clubVO = _clubVO;
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 138.0)] asLargeLoader:NO];
	[self.contentView addSubview:_imageLoadingView];
	
	_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 18.0, 100.0, 100.0)];
	_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	[self.contentView addSubview:_coverImageView];
	
	[[HONImageBroker sharedInstance] maskImageView:_coverImageView withMask:[UIImage imageNamed:@"clubCoverMask"]];
	
	_badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 55.0, 80, 30.0)];
	[self.contentView addSubview:_badgeImageView];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 128.0, 120.0, 20.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.textAlignment = NSTextAlignmentCenter;
	_nameLabel.text = _clubVO.clubName;
	[self.contentView addSubview:_nameLabel];

	
	if (_clubVO.clubID != 0) {
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_coverImageView.image = image;
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
		};
		
		if ([_clubVO.coverImagePrefix rangeOfString:@"defaultClubCover"].location != NSNotFound)
			_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
		
		else {
			[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]]
																	 cachePolicy:kURLRequestCachePolicy
																 timeoutInterval:[HONAppDelegate timeoutInterval]]
								   placeholderImage:nil
											success:imageSuccessBlock
											failure:imageFailureBlock];
		}
		
	} else
		_coverImageView.alpha = 1.0;
	
	
	if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
		_badgeImageView.image = [UIImage imageNamed:@"inviteOverlay"];
	
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
		_badgeImageView.image = [UIImage imageNamed:@"suggestionOverlay"];
	
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
		_badgeImageView.image = [UIImage imageNamed:@"lockedOverlay"];
	}
}

- (void)resetSubviews {
	for (UIView *view in self.contentView.subviews)
		[view removeFromSuperview];
	
	if (_imageLoadingView != nil)
		_imageLoadingView = nil;
	
	if (_coverImageView != nil)
		_coverImageView = nil;
	
	if (_nameLabel != nil)
		_nameLabel = nil;
	
	if (_badgeImageView != nil)
		_badgeImageView = nil;
}


-(void)applyTintThenReset:(BOOL)reset {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.125];
	
	if (reset) {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	}
	
	[_coverImageView setBackgroundColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	[UIView commitAnimations];
}

- (void)removeTint {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.125];
	[_coverImageView setBackgroundColor:[UIColor clearColor]];
	[UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[self removeTint];
}


#pragma mark - Navigation





@end
