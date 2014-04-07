//
//  HONUserClubViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 13:15 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONUserClubViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"

@interface HONUserClubViewCell ()
@end

@implementation HONUserClubViewCell
@synthesize delegate = _delegate;
@synthesize userClubVO = _userClubVO;


- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserClubVO:(HONUserClubVO *)userClubVO {
	_userClubVO = userClubVO;
	
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	coverImageView.alpha = 0.0;
	[self.contentView addSubview:coverImageView];
	
	[HONImagingDepictor maskImageView:coverImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		coverImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			coverImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_userClubVO.coverImagePrefix forBucketType:HONS3BucketTypeClubs completion:nil];
		
		coverImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			coverImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userClubVO.coverImagePrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:imageSuccessBlock
								   failure:imageFailureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 20.0, 130.0, 22.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userClubVO.clubName;
	[self.contentView addSubview:nameLabel];
	
	UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	editButton.frame = CGRectMake(220.0, 0.0, 74.0, 64.0);
	[editButton setBackgroundImage:[UIImage imageNamed:@"editButton_nonActive"] forState:UIControlStateNormal];
	[editButton setBackgroundImage:[UIImage imageNamed:@"editButton_Active"] forState:UIControlStateHighlighted];
	[editButton addTarget:self action:@selector(_goEdit) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:editButton];
}


#pragma mark - Navigation
- (void)_goEdit {
	[self.delegate userClubViewCell:self settingsForClub:_userClubVO];
}


@end
