//
//  HONTimelineCellSubjectView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/08/2013 @ 15:31 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"

#import "HONTimelineCellSubjectView.h"
#import "HONEmotionVO.h"
#import "HONChallengeVO.h"

#define kMAX_WIDTH 300.0f
#define kSPECIAL_COLOR [UIColor colorWithRed:0.424 green:1.000 blue:0.000 alpha:1.0]

@interface HONTimelineCellSubjectView ()
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) CGSize size;
@end


@implementation HONTimelineCellSubjectView

- (id)initAtOffsetY:(CGFloat)offsetY withSubjectNames:(NSArray *)subjectNames withUsername:(NSString *)username {
	if ((self = [super initWithFrame:CGRectMake(10.0, offsetY, 300.0, 70.0)])) {
		_username = username;
		_caption = [subjectNames firstObject];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kMAX_WIDTH, self.frame.size.height)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:40];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.shadowColor = [UIColor blackColor];
		_captionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_captionLabel.text = _caption;
		[self addSubview:_captionLabel];

//		[self _captionForSubject:subjectName];
//		[self _updateEmotion];
	}
	
	return self;
}

- (void)_updateEmotion {
//	HONEmotionVO *emotionVO = [HONChallengeAssistant emotionForOpponent:_challengeVO.creatorVO];
//	if (emotionVO != nil) {
//		self.frame = CGRectOffset(self.frame, 0.0, -50.0);
//		
//		UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(93.0, _captionLabel.frame.origin.y + _captionLabel.frame.size.height + 10.0, 94.0, 94.0)];
//		[self addSubview:emoticonImageView];
//		
//		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			emoticonImageView.image = image;
//		};
//		
//		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		};
//		
//		[emoticonImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.urlLarge]
//																   cachePolicy:kOrthodoxURLCachePolicy
//															   timeoutInterval:[HONAPICaller timeoutInterval]]
//								 placeholderImage:nil
//										  success:successBlock
//										  failure:failureBlock];
//	}
}

- (void)updateChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_username = _challengeVO.creatorVO.username;
	[self _captionForSubject:[_challengeVO.subjectNames firstObject]];
	[self _updateEmotion];
}


#pragma mark - Navigation
- (void)_goProfile {
}


#pragma mark - Data Manip
- (void)_captionForSubject:(NSString *)subject {
	_caption = subject;
	
	BOOL isFound = NO;
	_captionLabel.text = _caption;
	
	
	if (isFound)
		[_captionLabel setTextColor:kSPECIAL_COLOR range:NSMakeRange(0, [_captionLabel.text rangeOfString:@":"].location + 1)];
}


@end
