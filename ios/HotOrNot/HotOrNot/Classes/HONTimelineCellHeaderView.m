//
//  HONTimelineCellHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONTimelineCellHeaderView.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONEmotionVO.h"

@implementation HONTimelineCellHeaderView

- (id)initWithChallenge:(HONChallengeVO *)vo
{
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)])) {
		self.challengeVO = vo;
	}
	return self;
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO
{
	_challengeVO = challengeVO;
	
	if (_challengeVO != nil) {
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
		[self addSubview:avatarImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_challengeVO.creatorVO.avatarPrefix forAvatarBucket:YES completion:nil];
			avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_challengeVO.creatorVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		
		CGSize size;
		CGFloat maxNameWidth = 120.0;
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 14.0, maxNameWidth, 18.0)];
		nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.text = _challengeVO.creatorVO.username;
		[self addSubview:nameLabel];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 17.0, 50.0, 14.0)];
		timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.textColor = [UIColor whiteColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.addedDate];
		[self addSubview:timeLabel];
		
		if ([[HONDeviceTraits sharedInstance] isIOS7]) {
			size = [[_challengeVO.creatorVO.username stringByAppendingString:@"…"] boundingRectWithSize:CGSizeMake(maxNameWidth, 19.0)
																								options:NSStringDrawingTruncatesLastVisibleLine
																							 attributes:@{NSFontAttributeName:nameLabel.font}
																								context:nil].size;
		}
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = nameLabel.frame;
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
		
		/*
		 HONEmotionVO *emotionVO = [self _creatorEmotionVO];
		 CGFloat maxSubjectWidth = 320.0 - ((nameLabel.frame.size.width + 90.0) + ((int)(emotionVO != nil) * 22.0));
		 
		 UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameLabel.frame.size.width + 3.0), 9.0, maxSubjectWidth, 18.0)];
		 subjectLabel.font = [[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		 subjectLabel.textColor = [UIColor whiteColor];
		 subjectLabel.backgroundColor = [UIColor clearColor];
		 subjectLabel.text = _challengeVO.subjectName;
		 [self addSubview:subjectLabel];
		 
		 if ([[HONDeviceTraits sharedInstance] isIOS7]) {
		 size = [subjectLabel.text boundingRectWithSize:CGSizeMake(maxSubjectWidth, 18.0)
		 options:NSStringDrawingTruncatesLastVisibleLine
		 attributes:@{NSFontAttributeName:subjectLabel.font}
		 context:nil].size;
		 } //else
		 //			size = [subjectLabel.text sizeWithFont:subjectLabel.font constrainedToSize:CGSizeMake(maxSubjectWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		 
		 subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y, MIN(maxSubjectWidth, size.width), 18.0);
		 
		 //		NSLog(@"NAME:_[%@]_ <|> SUB:_[%@]_", NSStringFromCGSize(nameLabel.frame.size), NSStringFromCGSize(subjectLabel.frame.size));
		 
		 if (emotionVO != nil) {
		 UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(subjectLabel.frame.origin.x + subjectLabel.frame.size.width + 6.0, 10.0, 18.0, 18.0)];
		 emoticonImageView.image = [UIImage imageNamed:@"emoticon_white"];
		 [emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.urlSmallWhite] placeholderImage:nil];
		 [self addSubview:emoticonImageView];
		 }
		 */
	}
}

#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate timelineCellHeaderView:self showProfile:_challengeVO.creatorVO forChallenge:_challengeVO];
}


#pragma mark - Data Tally
- (HONEmotionVO *)_creatorEmotionVO {
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.hastagName isEqualToString:_challengeVO.subjectName]) {
			emotionVO = vo;
			break;
		}
	}
	
	return (emotionVO);
}

@end
