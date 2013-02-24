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
		self.backgroundColor = [UIColor orangeColor];
		
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 20.0, 12.0)];
		_statusLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:10];
		_statusLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel];
		
		UILabel *statusNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 17.0, 20.0, 4.0)];
		statusNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:4];
		statusNameLabel.textColor = [HONAppDelegate honBlueTxtColor];
		statusNameLabel.backgroundColor = [UIColor clearColor];
		statusNameLabel.textAlignment = NSTextAlignmentCenter;
		statusNameLabel.text = @"CHALLENGES";
		[self addSubview:statusNameLabel];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 20.0, 12.0)];
		_scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:10];
		_scoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_scoreLabel];
		
		UILabel *scoreNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 17.0, 20.0, 4.0)];
		scoreNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:4];
		scoreNameLabel.textColor = [HONAppDelegate honBlueTxtColor];
		scoreNameLabel.backgroundColor = [UIColor clearColor];
		scoreNameLabel.textAlignment = NSTextAlignmentCenter;
		scoreNameLabel.text = @"VOTES";
		[self addSubview:scoreNameLabel];
		
		_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 5.0, 20.0, 12.0)];
		_commentLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:10];
		_commentLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_commentLabel.backgroundColor = [UIColor clearColor];
		_commentLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_commentLabel];
		
		UILabel *commentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 17.0, 20.0, 4.0)];
		commentNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:4];
		commentNameLabel.textColor = [HONAppDelegate honBlueTxtColor];
		commentNameLabel.backgroundColor = [UIColor clearColor];
		commentNameLabel.textAlignment = NSTextAlignmentCenter;
		commentNameLabel.text = @"COMMENTS";
		[self addSubview:commentNameLabel];
	}
	
	return (self);
}

- (void)setAlerts:(NSDictionary *)dict {
	_statusLabel.text = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"status"] intValue]];
	_scoreLabel.text = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"score"] intValue]];
	_commentLabel.text = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"comments"] intValue]];
}

@end
