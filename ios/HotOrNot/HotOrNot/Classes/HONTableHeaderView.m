//
//  HONTableHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/07/2014 @ 13:16 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTableHeaderView.h"

@interface HONTableHeaderView ()
@end

@implementation HONTableHeaderView

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableHeaderHeight)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBG"]]];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 6.0, 200.0, 11.0)];
		label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:11];
		label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		label.backgroundColor = [UIColor clearColor];
		label.text = [title uppercaseString];
		[self addSubview:label];
	}
	
	return (self);
}


#pragma mark - Navigation


@end
