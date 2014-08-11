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
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *activityBGImageView;
@property (nonatomic, strong) UILabel *activityTotalLabel;
@end

@implementation HONActivityHeaderButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, 1.0, 93.0, 44.0)])) {
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		_button.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
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
		
		_activityTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kMaxActivityWidth, 44.0)];
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
	[[HONAPICaller sharedInstance] retrieveNewActivityForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
		
		__block int newTot = 0;
		[result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			HONActivityItemVO *vo = [HONActivityItemVO activityWithDictionary:obj];
			newTot += (int)([[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSinceDate:vo.sentDate] < 1800);
		}];
		
		NSLog(@"updateActivityBadge -[%@]- newTot:[%d]", [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]], newTot);
		[UIView animateWithDuration:0.25 delay:0.125 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut) animations:^(void) {
			_activityBGImageView.alpha = (newTot > 0);
		} completion:^(BOOL finished) {}];
		
//		_activityBGImageView.hidden = (newTot == 0);
	}];
}


@end
