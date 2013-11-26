//
//  HONTimelineCreatorHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONTimelineCreatorHeaderView.h"
#import "HONEmotionVO.h"

@interface HONTimelineCreatorHeaderView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@end

@implementation HONTimelineCreatorHeaderView
@synthesize delegate = _delegate;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)])) {
		//self.backgroundColor = [UIColor whiteColor];
		_challengeVO = vo;
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
		[self addSubview:avatarImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:_challengeVO.creatorVO.avatarURL];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_challengeVO.creatorVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							  placeholderImage:nil
									   success:successBlock
									   failure:failureBlock];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		
		CGSize size;
		CGFloat maxNameWidth = 110.0;
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, maxNameWidth, 18.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:nameLabel];
		
		if ([HONAppDelegate isIOS7]) {
			size = [[_challengeVO.creatorVO.username stringByAppendingString:@"…"] boundingRectWithSize:CGSizeMake(maxNameWidth, 19.0)
																								options:NSStringDrawingTruncatesLastVisibleLine
																							 attributes:@{NSFontAttributeName:nameLabel.font}
																								context:nil].size;
			
		} //else
//			size = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(maxNameWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		
		nameLabel.text = (size.width >= maxNameWidth) ? _challengeVO.creatorVO.username : [_challengeVO.creatorVO.username stringByAppendingString:@"…"];
		nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, MIN(maxNameWidth, size.width), size.height);
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = nameLabel.frame;
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
		
		HONEmotionVO *emotionVO = [self _creatorEmotionVO];
		CGFloat maxSubjectWidth = 320.0 - ((nameLabel.frame.size.width + 90.0) + ((int)(emotionVO != nil) * 22.0));
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameLabel.frame.size.width + 3.0), 9.0, maxSubjectWidth, 18.0)];
		subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _challengeVO.subjectName;
		[self addSubview:subjectLabel];
		
		if ([HONAppDelegate isIOS7]) {
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
//			emoticonImageView.image = [UIImage imageNamed:@"emoticon_white"];
			[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.urlSmallWhite] placeholderImage:nil];
			[self addSubview:emoticonImageView];
		}
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate timelineHeaderView:self showProfile:_challengeVO.creatorVO forChallenge:_challengeVO];
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
