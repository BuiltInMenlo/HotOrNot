//
//  HONTimelineCellSubjectView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/08/2013 @ 15:31 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "UILabel+FormattedText.h"

#import "HONTimelineCellSubjectView.h"

#define kMAX_WIDTH 280.0f
#define kSPECIAL_COLOR [UIColor colorWithRed:0.424 green:1.000 blue:0.000 alpha:1.0]


@interface HONTimelineCellSubjectView ()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic) CGSize size;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *username;
@end

@implementation HONTimelineCellSubjectView
@synthesize delegate = _delegate;

- (id)initAtOffsetY:(CGFloat)offsetY withSubjectName:(NSString *)subjectName withUsername:(NSString *)username {
	if ((self = [super initWithFrame:CGRectMake(0.0, offsetY, 320.0, 44.0)])) {
		_username = username;
		
		_bgImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"captionBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 24.0, 0.0, 24.0)]];
		[self addSubview:_bgImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kMAX_WIDTH, _bgImageView.frame.size.height)];
		_captionLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:22];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		[_bgImageView addSubview:_captionLabel];
		
		[self _captionForSubject:subjectName];
		_size = [[NSString stringWithFormat:@"  %@  ", _caption] boundingRectWithSize:CGSizeMake(kMAX_WIDTH, _captionLabel.frame.size.height)
																			  options:NSStringDrawingTruncatesLastVisibleLine
																		   attributes:@{NSFontAttributeName:_captionLabel.font}
																			  context:nil].size;
		if (_size.width > kMAX_WIDTH)
			_size = CGSizeMake(kMAX_WIDTH + 15.0, _size.height);
		
		
		_captionLabel.frame = CGRectMake(_captionLabel.frame.origin.x, _captionLabel.frame.origin.y - 2.0, _size.width, _captionLabel.frame.size.height);
		_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, _bgImageView.frame.origin.y, _size.width, _bgImageView.frame.size.height);
		self.frame = CGRectMake(160.0 - (_size.width * 0.5), self.frame.origin.y, _size.width, self.frame.size.height);
		
		UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		profileButton.frame = _bgImageView.frame;
		[profileButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:profileButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate timelineCellSubjectViewShowProfile:self];
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

@end
