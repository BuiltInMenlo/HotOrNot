//
//  HONFollowTabCellHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 1:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyCellHeaderView.h"
#import "HONUtilsSuite.h"
#import "HONDeviceIntrinsics.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"

const CGSize kVerifyAvatarSize = {60.0f, 60.0f};


@interface HONVerifyCellHeaderView ()
@property (nonatomic, retain) HONOpponentVO *opponentVO;
@property (nonatomic, strong) NSDictionary *verifyTabInfo;
@end

@implementation HONVerifyCellHeaderView

@synthesize delegate = _delegate;

- (id)initWithOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 100.0)])) {
		_opponentVO = opponentVO;
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((320.0 - kVerifyAvatarSize.width) * 0.5, 0.0, kVerifyAvatarSize.width, kVerifyAvatarSize.height)];
		[self addSubview:avatarImageView];
				
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.alpha = 0.0;
			avatarImageView.image = image;
			[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				avatarImageView.alpha = 1.0;
			}];
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_opponentVO.imagePrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_opponentVO.imagePrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		
		NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.alignment = NSTextAlignmentCenter;
		paragraphStyle.minimumLineHeight = 23.0;
		paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
		
		CGFloat width = 260.0;
		UILabel *ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 62.0, width, 33.0)];
		ctaLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:13];
		ctaLabel.textColor = [UIColor whiteColor];
		ctaLabel.backgroundColor = [UIColor clearColor];
		ctaLabel.shadowColor = [UIColor blackColor];
		ctaLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		ctaLabel.numberOfLines = 2;
		ctaLabel.attributedText = [[NSAttributedString alloc] initWithString:[[HONAppDelegate verifyCopyForKey:@"cta_txt"] stringByReplacingOccurrencesOfString:@"_{{USERNAME}}_" withString:_opponentVO.username] attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
		[self addSubview:ctaLabel];
		
		[ctaLabel sizeToFit];
		ctaLabel.frame = CGRectMake(ctaLabel.frame.origin.x, ctaLabel.frame.origin.y, width, ctaLabel.frame.size.height);
		self.frame = CGRectMake(0.0, 0.0, 320.0, ctaLabel.frame.origin.y + ctaLabel.frame.size.height);
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate cellHeaderView:self showProfileForUser:_opponentVO];
}


@end
