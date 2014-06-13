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
@end

@implementation HONClubCollectionViewCell
@synthesize clubType = _clubType;
@synthesize clubVO = _clubVO;
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setClubType:(HONClubType)clubType {
	
	_clubType = clubType;
	
	NSString *buttonAsset;
	SEL selector;
	
	if (_clubType == HONClubTypeOwner) {
		buttonAsset = @"";
		selector = @selector(_goEditClub);
		
	} else if (_clubType == HONClubTypeMember) {
		buttonAsset = @"quitClubButton";
		selector = @selector(_goQuitClub);
	
	} else if (_clubType == HONClubTypePending) {
		buttonAsset = @"joinClubButton";
		selector = @selector(_goJoinClub);
	
	} else if (_clubType == HONClubTypeOther) {
		buttonAsset = @"joinClubButton";
		selector = @selector(_goJoinClub);
		
	} else {
		buttonAsset = @"";
		selector = @selector(_goCreateClub);
		_coverImageView.image = [UIImage imageNamed:@"createClubButton_nonActive"];
	}
	
	
	_ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_ctaButton.frame = CGRectMake(99.0, 11.0, 44.0, 44.0);
	[_ctaButton setBackgroundImage:[UIImage imageNamed:[buttonAsset stringByAppendingString:@"_nonActive"]] forState:UIControlStateNormal];
	[_ctaButton setBackgroundImage:[UIImage imageNamed:[buttonAsset stringByAppendingString:@"_Active"]] forState:UIControlStateHighlighted];
	[_ctaButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:_ctaButton];
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	
	_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(22.0, 18.0, 100.0, 100.0)];
	_coverImageView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreyColor];
	[self.contentView addSubview:_coverImageView];
	
	[HONImagingDepictor maskImageView:_coverImageView withMask:[UIImage imageNamed:@"clubCoverMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_coverImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_clubVO.coverImagePrefix forBucketType:HONS3BucketTypeClubs completion:nil];
		
		_coverImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	};
	
	[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubVO.coverImagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:imageSuccessBlock
								   failure:imageFailureBlock];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 126.0, 120.0, 20.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.textAlignment = NSTextAlignmentCenter;
	_nameLabel.text = _clubVO.clubName;
	[self.contentView addSubview:_nameLabel];
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


@end
