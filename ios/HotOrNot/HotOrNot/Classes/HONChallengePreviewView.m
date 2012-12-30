//
//  HONChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+WebCache.h"

#import "HONChallengePreviewView.h"
#import "HONAppDelegate.h"

@interface HONChallengePreviewView()
@property (nonatomic, retain) HONChallengeVO *challengeVO;
@end


@implementation HONChallengePreviewView

- (id)initWithFrame:(CGRect)frame andChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:frame])) {
		_challengeVO = vo;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)];
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		[self addSubview:imageView];
	}
	
	return (self);
}

@end
