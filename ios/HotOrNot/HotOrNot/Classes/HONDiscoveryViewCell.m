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
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 117.0)];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (void)setLChallengeVO:(HONChallengeVO *)lChallengeVO {
	_lChallengeVO = lChallengeVO;
	
	UIView *lHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 73.0, 73.0)];
	lHolderView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.0];
	lHolderView.clipsToBounds = YES;
	[self addSubview:lHolderView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10.0, 73.0, 97.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.creatorImgPrefix]] placeholderImage:nil];
	[lHolderView addSubview:lImageView];
	
	UIView *rHolderView = [[UIView alloc] initWithFrame:CGRectMake(83.0, 10.0, 73.0, 73.0)];
	rHolderView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.0];
	rHolderView.clipsToBounds = YES;
	[self addSubview:rHolderView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10.0, 73.0, 97.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.challengerImgPrefix]] placeholderImage:nil];
	[rHolderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 97.0, 140.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _lChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(16.0, 15.0, 129.0, 72.0);
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	UIView *lHolderView = [[UIView alloc] initWithFrame:CGRectMake(164.0, 10.0, 73.0, 73.0)];
	lHolderView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.0];
	lHolderView.clipsToBounds = YES;
	[self addSubview:lHolderView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10.0, 73.0, 97.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.creatorImgPrefix]] placeholderImage:nil];
	[lHolderView addSubview:lImageView];
	
	
	UIView *rHolderView = [[UIView alloc] initWithFrame:CGRectMake(237.0, 10.0, 73.0, 73.0)];
	rHolderView.backgroundColor = [UIColor colorWithWhite:0.875 alpha:1.0];
	rHolderView.clipsToBounds = YES;
	[self addSubview:rHolderView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10.0, 73.0, 97.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.challengerImgPrefix]] placeholderImage:nil];
	[rHolderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(164.0, 97.0, 140.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _rChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(172.0, 15.0, 129.0, 72.0);
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
