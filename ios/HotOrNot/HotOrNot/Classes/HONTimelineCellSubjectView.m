//
//  HONTimelineCellSubjectView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/08/2013 @ 15:31 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"
#import "UILabel+FormattedText.h"

#import "HONTimelineCellSubjectView.h"
#import "HONFontAllocator.h"
#import "HONEmotionVO.h"
#import "HONChallengeVO.h"

#define kMAX_WIDTH 300.0f
#define kSPECIAL_COLOR [UIColor colorWithRed:0.424 green:1.000 blue:0.000 alpha:1.0]

@implementation HONTimelineCellSubjectView
{
	UILabel *_captionLabel;
	CGSize _size;
	NSString *_caption;
	NSString *_username;
}

- (id)initAtOffsetY:(CGFloat)offsetY withSubjectName:(NSString *)subjectName withUsername:(NSString *)username {
	if ((self = [super initWithFrame:CGRectMake(10.0, offsetY, 300.0, 70.0)])) {
		_username = username;
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kMAX_WIDTH, self.frame.size.height)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:40];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.shadowColor = [UIColor blackColor];
		_captionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		[self addSubview:_captionLabel];

		[self _captionForSubject:subjectName];
		[self _updateEmotion];
	}
	
	return self;
}

- (void)_updateEmotion
{
	HONEmotionVO *emotionVO = [self _creatorEmotionVO];
	if (emotionVO != nil) {
		self.frame = CGRectOffset(self.frame, 0.0, -50.0);
		
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(93.0, _captionLabel.frame.origin.y + _captionLabel.frame.size.height + 10.0, 94.0, 94.0)];
		[self addSubview:emoticonImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			emoticonImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		[emoticonImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.urlLarge] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
								 placeholderImage:nil
										  success:successBlock
										  failure:failureBlock];
	}
}

- (void)updateChallenge:(HONChallengeVO *)challengeVO
{
	_username = challengeVO.creatorVO.username;
	[self _captionForSubject:challengeVO.subjectName];
	[self _updateEmotion];
}


#pragma mark - Navigation
- (void)_goProfile {
}


#pragma mark - Data Manip
- (void)_captionForSubject:(NSString *)subject {
	_caption = subject;
	
	BOOL isFound = NO;
	for (NSDictionary *dict in [HONAppDelegate specialSubjects]) {
		if ([[subject lowercaseString] isEqualToString:[[dict objectForKey:@"name"] lowercaseString]]) {
			isFound = YES;
			_caption = [[dict objectForKey:@"format"] stringByReplacingOccurrencesOfString:@"_{{SUBJECT_NAME}}_" withString:[dict objectForKey:@"name"]];
			_caption = [_caption stringByReplacingOccurrencesOfString:@"_{{USERNAME}}_" withString:_username];
		}
	}
	
	_captionLabel.text = _caption;
	
	
	if (isFound)
		[_captionLabel setTextColor:kSPECIAL_COLOR range:NSMakeRange(0, [_captionLabel.text rangeOfString:@":"].location + 1)];
}

- (HONEmotionVO *)_creatorEmotionVO {
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate composeEmotions]) {
		if ([vo.emotionName isEqualToString:_caption]) {
			emotionVO = vo;
			break;
		}
	}
	
	if (emotionVO == nil) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
			if ([vo.emotionName isEqualToString:_caption]) {
				emotionVO = vo;
				break;
			}
		}
	}
	
	return (emotionVO);
}

@end
