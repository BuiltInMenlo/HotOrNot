//
//  HONSearchToggleHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.18.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchToggleHeaderView.h"

@interface HONSearchToggleHeaderView()

@property (nonatomic) BOOL isUser;
@end

@implementation HONSearchToggleHeaderView

@synthesize userButton = _userButton;
@synthesize subjectButton = _subjectButton;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_userButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_userButton.frame = CGRectMake(0.0, 0.0, 160.0, 30.0);
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
		[_userButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateSelected];
		//[self addSubview:_userButton];
		
		_subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subjectButton.frame = CGRectMake(160.0, 0.0, 160.0, 30.0);
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
		[_subjectButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateSelected];
		//[self addSubview:_subjectButton];
	}
	
	return (self);
}


#pragma mark - Navigation

@end
