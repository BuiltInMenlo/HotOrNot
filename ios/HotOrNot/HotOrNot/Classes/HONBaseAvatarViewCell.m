//
//  HONBaseAvatarViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/5/13 @ 9:56 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONBaseAvatarViewCell.h"
#import "HONUtilsSuite.h"
#import "HONFontAllocator.h"
#import "HONColorAuthority.h"
#import "HONImagingDepictor.h"

@interface HONBaseAvatarViewCell ()
@end

@implementation HONBaseAvatarViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;


- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	_userVO = userVO;
	
	switch (_userVO.userID) {
		case 14434:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/46a7627f2d458ebbedd54fe64cb9149762489a1a9e1c8fca213d217cf09067d4-1379198239";
			break;
			
		case 14361:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/01b37fcac9e842999485811756d753a1_d8ea0f6cdb21494fbd1fc84bc259c3bc-1397093806";
			break;
			
		case 14440:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/8268d1cb4608e0fce19ddc30d1a47a6d247769bc1301f9d1b99c2c5248ce3148-1379717258";
			break;
			
		case 14450:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/284d44ce1a9d4e3da3d0f3c7868b5e96_f76748994f464b4f9dae99c27f1ac9ef-1385609098";
			break;
			
		case 14372:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/d68897a23add889c1328a8ccc750820a95ec1f013e9159573108147d55ad4c3b-1379181237";
			break;
			
		case 14379:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/46a7627f2d458ebbedd54fe64cb9149762489a1a9e1c8fca213d217cf09067d4-1379198239";
			break;
			
		case 14432:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/08b7adc9621b431eaf6d9bb594917f71_57d0327c17c045b387c65547989f9b07-1385529261";
			break;
			
		case 82169:
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/d68d766e33594de4bb65da6280dd5b9b_dae17c43b4ad40399dd47635420126c0-1394177349";
			break;
			
		case 90781:
			_userVO.username = @"1DFan";
			_userVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/10544713617e46c1aac6acbb04cf0496_b3a09b56db5f461985f2176a383d1e08-1385444745";
			break;
	}
	
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 8.0, 48.0, 48.0)];
	_avatarImageView.alpha = 0.0;
	[self.contentView addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_userVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		_avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 20.0, 195.0, 22.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	_nameLabel.backgroundColor = [UIColor clearColor];
	_nameLabel.text = _userVO.username;
	[self.contentView addSubview:_nameLabel];
}

- (void)didSelect {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellSelectedBG"]];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate avatarViewCell:self showProfileForUser:_userVO];
}


#pragma mark - UI Presentation
- (void)_resetBG {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
}


@end
