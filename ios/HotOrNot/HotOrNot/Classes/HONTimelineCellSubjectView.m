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

#define kMAX_WIDTH 280.0f
#define kSPECIAL_COLOR [UIColor colorWithRed:0.424 green:1.000 blue:0.000 alpha:1.0]


@interface HONTimelineCellSubjectView ()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *username;
@end

@implementation HONTimelineCellSubjectView
@synthesize delegate = _delegate;

- (id)initAtOffsetY:(CGFloat)offsetY withSubjectName:(NSString *)subjectName withUsername:(NSString *)username {
	if ((self = [super initWithFrame:CGRectMake(10.0, offsetY, 320.0, 70.0)])) {
		_username = username;
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kMAX_WIDTH, self.frame.size.height)];
		_captionLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:28];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.numberOfLines = 0;
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_captionLabel];
		
		[self _captionForSubject:subjectName];
		
		
		_size = [_caption boundingRectWithSize:CGSizeMake(kMAX_WIDTH, _captionLabel.frame.size.height)
									   options:NSStringDrawingUsesLineFragmentOrigin
									attributes:@{NSFontAttributeName:_captionLabel.font}
									   context:nil].size;
		if (_size.width > kMAX_WIDTH)
			_size = CGSizeMake(kMAX_WIDTH, _size.height);
		
		_captionLabel.frame = CGRectMake(_captionLabel.frame.origin.x, _captionLabel.frame.origin.y, _captionLabel.frame.size.width, _size.height);
		
		
		HONEmotionVO *emotionVO = [self _creatorEmotionVO];
		if (emotionVO != nil) {
			UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(113.0, _captionLabel.frame.origin.y + _captionLabel.frame.size.height + 10.0, 94.0, 94.0)];
			[self addSubview:emoticonImageView];
			
			void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				self.frame = CGRectOffset(self.frame, 0.0, -50.0);
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
	
	return (self);
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
		if ([vo.hastagName isEqualToString:_caption]) {
			emotionVO = vo;
			break;
		}
	}
	
	if (emotionVO == nil) {
		for (HONEmotionVO *vo in [HONAppDelegate replyEmotions]) {
			if ([vo.hastagName isEqualToString:_caption]) {
				emotionVO = vo;
				break;
			}
		}
	}
	
	return (emotionVO);
}

@end
