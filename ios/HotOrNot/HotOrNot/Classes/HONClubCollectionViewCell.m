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


@interface HONClubCollectionViewCell ()
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic) SEL currSelector;
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
		
		_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 18.0, 100.0, 100.0)];
		_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
		[self.contentView addSubview:_coverImageView];
		
		[HONImagingDepictor maskImageView:_coverImageView withMask:[UIImage imageNamed:@"clubCoverMask"]];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 128.0, 120.0, 20.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_nameLabel];
		
		_ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_ctaButton.frame = CGRectMake(77.0, 11.0, 44.0, 44.0);
		_ctaButton.alpha = 0.0;
		[self.contentView addSubview:_ctaButton];
	}
	
	return (self);
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	_nameLabel.text = _clubVO.clubName;
	_overlayImageView.hidden = YES;
	_coverImageView.alpha = 0.0;
	[_overlayImageView.layer removeAllAnimations];
	
	if (_clubVO.clubID != 0) {
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_coverImageView.image = image;
			[UIView animateWithDuration:0.25 animations:^(void) {
				_coverImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
			}];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
			
			_coverImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapMediumSize];
			[UIView animateWithDuration:0.25 animations:^(void) {
				_coverImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
			}];
		};
		
		[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]]
																 cachePolicy:kURLRequestCachePolicy
															 timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:imageFailureBlock];
	
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}
	
	
	NSString *buttonAsset;
	SEL newSelector;
	
	if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeOwner) {
		buttonAsset = @"ownerClubButton";
		newSelector = @selector(_goCreateClub);//(_clubVO.clubType == HONClubTypeAutoGen) ? @selector(_goCreateClub) : @selector(_goEditClub);
		
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeMember) {
		buttonAsset = @"quitClubButton";
		newSelector = @selector(_goQuitClub);
		
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypePending) {
		buttonAsset = @"joinClubButton";
		newSelector = @selector(_goJoinClub);
		
		if (_overlayImageView != nil) {
			[_overlayImageView.layer removeAllAnimations];
			_overlayImageView = nil;
		}
		
		_overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clubsInviteOverlay"]];
		_overlayImageView.frame = CGRectOffset(_overlayImageView.frame, 0.0, 9.0);
		[self.contentView addSubview:_overlayImageView];
		[self _cycleOverlay:_overlayImageView];
		
	} else if (_clubVO.clubEnrollmentType == HONClubEnrollmentTypeAutoGen) {
		buttonAsset = @"blankClubButton";
		newSelector = @selector(_goCreateClub);
		
	} else {
		buttonAsset = @"blankClubButton";
		newSelector = nil;
		_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	}
	
	
	if (_currSelector != nil)
		[_ctaButton removeTarget:self action:_currSelector forControlEvents:UIControlEventTouchUpInside];
	
	
	_currSelector = newSelector;
	[_ctaButton setBackgroundImage:[UIImage imageNamed:[buttonAsset stringByAppendingString:@"_nonActive"]] forState:UIControlStateNormal];
	[_ctaButton setBackgroundImage:[UIImage imageNamed:[buttonAsset stringByAppendingString:@"_Active"]] forState:UIControlStateHighlighted];
	[_ctaButton addTarget:self action:_currSelector forControlEvents:UIControlEventTouchUpInside];
	
//	[UIView animateWithDuration:0.0625 delay:0.125 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction) animations:^(void) {
//		_ctaButton.alpha = 1.0;
//	} completion:nil];
}


- (void)resetSubviews {
	for (UIView *view in self.contentView.subviews)
		[view removeFromSuperview];
	
	if (_coverImageView != nil)
		_coverImageView = nil;
	
	if (_nameLabel != nil)
		_nameLabel = nil;
	
	if (_ctaButton != nil)
		_ctaButton = nil;
	
	if (_overlayImageView != nil) {
		[_overlayImageView.layer removeAllAnimations];
		_overlayImageView = nil;
	}
	
	
	_currSelector = nil;
}


#pragma mark - Navigation
- (void)_goDeleteClub {
	if ([self.delegate respondsToSelector:@selector(clubViewCell:deleteClub:)])
		[self.delegate clubViewCell:self deleteClub:_clubVO];
}

- (void)_goEditClub {
	if ([self.delegate respondsToSelector:@selector(clubViewCell:editClub:)])
		[self.delegate clubViewCell:self editClub:_clubVO];
}

- (void)_goJoinClub {
	if ([self.delegate respondsToSelector:@selector(clubViewCell:joinClub:)])
		[self.delegate clubViewCell:self joinClub:_clubVO];
}

- (void)_goQuitClub {
	if ([self.delegate respondsToSelector:@selector(clubViewCell:quitClub:)])
	[self.delegate clubViewCell:self quitClub:_clubVO];
}

- (void)_goCreateClub {
	if ([self.delegate respondsToSelector:@selector(clubViewCellCreateClub:)])
		[self.delegate clubViewCellCreateClub:self];
}


- (void)_cycleOverlay:(UIView *)overlayView {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
		overlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
			overlayView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[self _cycleOverlay:overlayView];
		}];
	}];
}


@end
