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
@property (nonatomic, strong) UIView *coverOverlayView;
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
//		self.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 138.0)] asLargeLoader:NO];
	[self.contentView addSubview:_imageLoadingView];
	
	_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 16.0, 105.0, 105.0)];
	_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	[self.contentView addSubview:_coverImageView];
	
	[[HONViewDispensor sharedInstance] maskView:_coverImageView withMask:[UIImage imageNamed:@"clubCoverMask"]];
	
//	UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clubCoverMask"]];
//	overlayImageView.frame = _coverOverlayView.frame;
//	[self.contentView addSubview:overlayImageView];
	
//	_coverOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
	_coverOverlayView = [[UIView alloc] initWithFrame:_coverImageView.frame];
	_coverOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
//	_coverOverlayView.clipsToBounds = YES;
	_coverOverlayView.alpha = 0.0;
	[self.contentView addSubview:_coverOverlayView];
	
	[[HONViewDispensor sharedInstance] maskView:_coverOverlayView withMask:[UIImage imageNamed:@"clubCoverMask"]];
	
	_badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-4.0, 10.0, 44.0, 44.0)];
	[self.contentView addSubview:_badgeImageView];
	
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 126.0, 120.0, 20.0)];
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
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
		};
		
		if ([_clubVO.coverImagePrefix rangeOfString:@"defaultClubCover"].location != NSNotFound)
			_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
		
		else {
			[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]]
																	 cachePolicy:kOrthodoxURLCachePolicy
																 timeoutInterval:[HONAPICaller timeoutInterval]]
								   placeholderImage:nil
											success:imageSuccessBlock
											failure:imageFailureBlock];
		}
		
	} else
		_coverImageView.alpha = 1.0;
	
	
	if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
		_badgeImageView.image = [UIImage imageNamed:@"inviteIcon"];
	
//	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeSuggested) {
//		_badgeImageView.image = [UIImage imageNamed:@"suggestionOverlay"];
//	
//	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeThreshold) {
//		_badgeImageView.image = [UIImage imageNamed:@"lockedOverlay"];
//		_badgeImageView.hidden = YES;
	}
}

- (void)resetSubviews {
	for (UIView *view in self.contentView.subviews)
		[view removeFromSuperview];
	
	if (_imageLoadingView != nil)
		_imageLoadingView = nil;
	
	if (_coverImageView != nil)
		_coverImageView = nil;
	
	if (_coverOverlayView != nil)
		_coverOverlayView = nil;
	
	if (_nameLabel != nil)
		_nameLabel = nil;
	
	if (_badgeImageView != nil)
		_badgeImageView = nil;
}


-(void)applyTouchOverlayAndReset:(BOOL)reset {
	[UIView animateWithDuration:0.025 animations:^(void) {
		_coverOverlayView.alpha = 1.0;
	} completion:^(BOOL finished) {
		if (reset)
			[self performSelector:@selector(removeTouchOverlay) withObject:nil afterDelay:0.125];
	}];
}

- (void)removeTouchOverlay {
	_coverOverlayView.alpha = 0.0;
}


#pragma mark - Navigation


@end
