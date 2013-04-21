//
//  HONAlertPopOverView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAlertPopOverView.h"
#import "HONAppDelegate.h"

@interface HONAlertPopOverView()
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@end


@implementation HONAlertPopOverView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39.0, 39.0)];
		bgImageView.image = [UIImage imageNamed:@"notificationBG"];
		[self addSubview:bgImageView];
		
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 39.0, 39.0)];
		_statusLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel];
		
		
//		UIImageView *statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 15.0, 24.0, 24.0)];
//		statusImageView.image = [UIImage imageNamed:@"notificationCameraIcon"];
//		[self addSubview:statusImageView];
//		
//		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 22.0, 32.0, 12.0)];
//		_statusLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		_statusLabel.textColor = [UIColor whiteColor];
//		_statusLabel.backgroundColor = [UIColor clearColor];
//		_statusLabel.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:_statusLabel];
//		
//		
//		UIImageView *scoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(71.0, 15.0, 24.0, 24.0)];
//		scoreImageView.image = [UIImage imageNamed:@"notificationHeartIcon"];
//		[self addSubview:scoreImageView];
//		
//		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(93.0, 22.0, 32.0, 12.0)];
//		_scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		_scoreLabel.textColor = [UIColor whiteColor];
//		_scoreLabel.backgroundColor = [UIColor clearColor];
//		_scoreLabel.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:_scoreLabel];
//		
//		
//		UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(132.0, 15.0, 24.0, 24.0)];
//		commentImageView.image = [UIImage imageNamed:@"notificationCommentIcon"];
//		[self addSubview:commentImageView];
//		
//		_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(154.0, 22.0, 32.0, 12.0)];
//		_commentLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		_commentLabel.textColor = [UIColor whiteColor];
//		_commentLabel.backgroundColor = [UIColor clearColor];
//		_commentLabel.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:_commentLabel];
	}
	
	return (self);
}

- (void)setAlerts:(NSDictionary *)dict {
	int tot = [[dict objectForKey:@"status"] intValue] + [[dict objectForKey:@"score"] intValue] + [[dict objectForKey:@"comments"] intValue];
	_statusLabel.text = (tot > 10) ? @"10+" : [NSString stringWithFormat:@"%d", tot];
	
//	_statusLabel.text = ([[dict objectForKey:@"status"] intValue] > 10) ? @"10+" : [NSString stringWithFormat:@"%d", [[dict objectForKey:@"status"] intValue]];
//	_scoreLabel.text = ([[dict objectForKey:@"score"] intValue] > 10) ? @"10+" : [NSString stringWithFormat:@"%d", [[dict objectForKey:@"score"] intValue]];
//	_commentLabel.text = ([[dict objectForKey:@"comments"] intValue] > 10) ? @"10+" : [NSString stringWithFormat:@"%d", [[dict objectForKey:@"comments"] intValue]];
}

@end
