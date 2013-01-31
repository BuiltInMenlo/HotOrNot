//
//  HONVoteSubjectViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteSubjectViewCell.h"
#import "HONAppDelegate.h"

@interface HONVoteSubjectViewCell()
@property (nonatomic, strong) NSMutableArray *challenges;
@end

@implementation HONVoteSubjectViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 128.0)];
		bgImgView.image = [UIImage imageNamed:@"rowWhite_nonActive"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

@end
