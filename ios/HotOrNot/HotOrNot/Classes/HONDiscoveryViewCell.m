//
//  HONDiscoveryViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONDiscoveryViewCell.h"

@implementation HONDiscoveryViewCell

@synthesize lChallengeVO = _lChallengeVO;
@synthesize rChallengeVO = _rChallengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)didSelectLeftChallenge {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_Active"] : [UIImage imageNamed:@"rowWhite_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)didSelectRightChallenge {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_Active"] : [UIImage imageNamed:@"rowWhite_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBGLeft {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_nonActive"] : [UIImage imageNamed:@"rowWhite_nonActive"];
}

- (void)_resetBGRight {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_nonActive"] : [UIImage imageNamed:@"rowWhite_nonActive"];
}

@end
