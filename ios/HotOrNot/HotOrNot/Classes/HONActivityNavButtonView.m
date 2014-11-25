//
//  HONActivityNavButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONActivityNavButtonView.h"

@interface HONActivityNavButtonView ()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation HONActivityNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 10.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(44.0, 44.0));
		[_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_button setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
		_button.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
		[_button setTitle:@"…" forState:UIControlStateNormal];
		[_button setTitle:@"…" forState:UIControlStateHighlighted];
	}
	
	return (self);
}

- (void)updateActivityBadge {
	[[HONAPICaller sharedInstance] retrieveActivityTotalForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSString *result) {
		NSLog(@"ACTIVITY:[%@]", result);
		[_button setTitle:[@"" stringFromInt:[result intValue]] forState:UIControlStateNormal];
		[_button setTitle:[@"" stringFromInt:[result intValue]] forState:UIControlStateHighlighted];
	}];
}

@end
