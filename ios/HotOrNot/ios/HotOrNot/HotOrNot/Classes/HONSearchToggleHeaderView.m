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
	}
	
	return (self);
}


#pragma mark - Navigation

@end
