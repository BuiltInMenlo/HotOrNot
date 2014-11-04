//
//  HONActivityHeaderButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONActivityHeaderButtonView.h"

const CGPoint kOrthodoxActivityCenterPt = {87.0, 22.0};
const CGFloat kMaxActivityWidth = 44.0;

@interface HONActivityHeaderButtonView ()
@property (nonatomic, strong) UIImageView *activityBGImageView;
@property (nonatomic, strong) UILabel *activityTotalLabel;
@property (nonatomic) BOOL isFirstRun;
@end

@implementation HONActivityHeaderButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 93.0, 44.0)])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_completedFirstRun:) name:@"COMPLETED_FIRST_RUN" object:nil];
		
		
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		_button.frame = CGRectMakeFromSize(self.frame.size);//CGRectMake(0.0, 0.0, 93.0, 44.0);
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateSelected];
		[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_button];
		
		_activityBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityDot"]];
		[_activityBGImageView setCenter:kOrthodoxActivityCenterPt];
//		_activityBGImageView.hidden = YES;
		_activityBGImageView.alpha = 0.0;
		[self addSubview:_activityBGImageView];
		
		_activityTotalLabel = [[UILabel alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(kMaxActivityWidth, 44.0))];
		_activityTotalLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		_activityTotalLabel.textColor = [UIColor whiteColor];
		_activityTotalLabel.backgroundColor = [UIColor clearColor];
		_activityTotalLabel.textAlignment = NSTextAlignmentCenter;
		_activityTotalLabel.text = @"N";
		[_activityBGImageView addSubview:_activityTotalLabel];
		
		[self updateActivityBadge];
	}
	
	return (self);
}

- (void)updateActivityBadge {
//	[[HONAPICaller sharedInstance] retrieveNewActivityForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
//		
//		__block int newTot = 0;
//		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			HONActivityItemVO *vo = [HONActivityItemVO activityWithDictionary:obj];
//			newTot += (int)([[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSinceDate:vo.sentDate] < 1800);
//		}];
//		
//		float delay = 0.125;
//		if (_isFirstRun) {
//			newTot++;
//			delay += 0.50;
//			_isFirstRun = NO;
//		}
//	
//		NSLog(@"updateActivityBadge -[%@]- newTot:[%d]", [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]], newTot);
//		[UIView animateWithDuration:0.25 delay:delay options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut) animations:^(void) {
//			_activityBGImageView.alpha = (newTot > 0);
//		} completion:^(BOOL finished) {}];
//	}];
}


- (void)_completedFirstRun:(NSNotification *)notification {
	NSLog(@"::|> _completedFirstRun <|::");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"COMPLETED_FIRST_RUN" object:nil];
	
	_isFirstRun = YES;
	[UIView animateWithDuration:0.25 delay:0.125 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut) animations:^(void) {
		_activityBGImageView.alpha = 1.0;
	} completion:^(BOOL finished) {}];
}


@end
