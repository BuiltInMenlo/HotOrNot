//
//  HONUserClubViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 13:15 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONUserClubViewCell.h"

@interface HONUserClubViewCell ()
@property (nonatomic) BOOL isInviteCell;
@end

@implementation HONUserClubViewCell
@synthesize delegate = _delegate;
@synthesize userClubVO = _userClubVO;


- (id)initAsInviteCell:(BOOL)isInvite {
	if ((self = [super init])) {
		[self hideChevron];
		
		_isInviteCell = isInvite;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserClubVO:(HONUserClubVO *)userClubVO {
	_userClubVO = userClubVO;
	
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 8.0, 48.0, 48.0)];
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
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 23.0, 200.0, 18.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userClubVO.clubName;
	[self.contentView addSubview:nameLabel];
	
	UIButton *takeActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
	takeActionButton.frame = CGRectMake(248.0, 0.0, 74.0, 64.0);
	[takeActionButton setBackgroundImage:[UIImage imageNamed:(_isInviteCell) ? @"acceptButton_nonActive" : @"editButton_nonActive"] forState:UIControlStateNormal];
	[takeActionButton setBackgroundImage:[UIImage imageNamed:(_isInviteCell) ? @"acceptButton_Active" : @"editButton_Active"] forState:UIControlStateHighlighted];
	[takeActionButton addTarget:self action:(_isInviteCell) ? @selector (_goAcceptInvite) : @selector(_goEditSettings) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:takeActionButton];
}


#pragma mark - Navigation
- (void)_goAcceptInvite {
	[self.delegate userClubViewCell:self acceptInviteForClub:_userClubVO];
}

- (void)_goEditSettings {
	[self.delegate userClubViewCell:self settingsForClub:_userClubVO];
}


@end
