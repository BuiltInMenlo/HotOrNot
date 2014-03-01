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

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowBackground"]];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserClubVO:(HONUserClubVO *)userClubVO {
	_userClubVO = userClubVO;
	
	UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	coverImageView.alpha = 0.0;
	[self.contentView addSubview:coverImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		coverImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			coverImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_userClubVO.coverImagePrefix forAvatarBucket:YES completion:nil];
		
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
	
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(280.0, 0.0, 44.0, 44.0);
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"feedChevron_nonActive"] forState:UIControlStateNormal];
	[settingsButton setBackgroundImage:[UIImage imageNamed:@"feedChevron_Active"] forState:UIControlStateHighlighted];
	[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:settingsButton];
}


#pragma mark - Navigation
- (void)_goSettings {
	[self.delegate userClubViewCell:self settingsForClub:_userClubVO];
}


@end
