//
//  HONDiscoveryViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONDiscoveryViewCell.h"
#import "HONAppDelegate.h"

@interface HONDiscoveryViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation HONDiscoveryViewCell

@synthesize lChallengeVO = _lChallengeVO;
@synthesize rChallengeVO = _rChallengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (void)setLChallengeVO:(HONChallengeVO *)lChallengeVO {
	_lChallengeVO = lChallengeVO;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 16.0, 140.0, 74.0)];
	bgImageView.image = [UIImage imageNamed:@"discoveryBackground"];
	[self addSubview:bgImageView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 7.0, 62.0, 60.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.creatorImgPrefix]] placeholderImage:nil];
	[bgImageView addSubview:lImageView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(72.0, 7.0, 62.0, 60.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.challengerImgPrefix]] placeholderImage:nil];
	[bgImageView addSubview:rImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 90.0, 140.0, 14.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	subjectLabel.textColor = [HONAppDelegate honGreyTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _lChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = bgImageView.frame;
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(162.0, 16.0, 140.0, 74.0)];
	bgImageView.image = [UIImage imageNamed:@"discoveryBackground"];
	[self addSubview:bgImageView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 7.0, 62.0, 60.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.creatorImgPrefix]] placeholderImage:nil];
	[bgImageView addSubview:lImageView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(72.0, 7.0, 62.0, 60.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.challengerImgPrefix]] placeholderImage:nil];
	[bgImageView addSubview:rImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(167.0, 90.0, 140.0, 14.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	subjectLabel.textColor = [HONAppDelegate honGreyTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _rChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = bgImageView.frame;
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}


#pragma mark - Navigation
- (void)_goSelectLeft {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_LEFT_DISCOVERY_CHALLENGE" object:_lChallengeVO];
}

- (void)_goSelectRight {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_RIGHT_DISCOVERY_CHALLENGE" object:_rChallengeVO];
}

#pragma mark - UI Presentation
- (void)didSelectLeftChallenge {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_Active"] : [UIImage imageNamed:@"rowWhite_Active"];
	[self performSelector:@selector(_resetBGLeft) withObject:nil afterDelay:0.33];
}

- (void)didSelectRightChallenge {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_Active"] : [UIImage imageNamed:@"rowWhite_Active"];
	[self performSelector:@selector(_resetBGRight) withObject:nil afterDelay:0.33];
}

- (void)_resetBGLeft {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_nonActive"] : [UIImage imageNamed:@"rowWhite_nonActive"];
}

- (void)_resetBGRight {
	//_bgImageView.image = (_isGrey) ? [UIImage imageNamed:@"rowGray_nonActive"] : [UIImage imageNamed:@"rowWhite_nonActive"];
}

@end
