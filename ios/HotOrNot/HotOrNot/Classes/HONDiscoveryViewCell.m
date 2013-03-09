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
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (void)setLChallengeVO:(HONChallengeVO *)lChallengeVO {
	_lChallengeVO = lChallengeVO;
	
	NSString *lImgURL = [NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.creatorImgPrefix];
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 9.0, 50.0, 50.0)];
	lImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[lImageView setImageWithURL:[NSURL URLWithString:lImgURL] placeholderImage:nil];
	[self addSubview:lImageView];
	
	NSString *rImgURL = [NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.challengerImgPrefix];
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70.0, 9.0, 50.0, 50.0)];
	rImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[rImageView setImageWithURL:[NSURL URLWithString:rImgURL] placeholderImage:nil];
	[self addSubview:rImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 55.0, 140.0, 14.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:12];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _lChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(14.0, 9.0, 120.0, 70.0);
	[selectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	NSString *lImgURL = [NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.creatorImgPrefix];
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(180.0, 9.0, 50.0, 50.0)];
	lImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[lImageView setImageWithURL:[NSURL URLWithString:lImgURL] placeholderImage:nil];
	[self addSubview:lImageView];
	
	NSString *rImgURL = [NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.challengerImgPrefix];
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(230.0, 9.0, 50.0, 50.0)];
	rImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[rImageView setImageWithURL:[NSURL URLWithString:rImgURL] placeholderImage:nil];
	[self addSubview:rImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(180.0, 55.0, 140.0, 14.0)];
	subjectLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:12];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _rChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(180.0, 9.0, 120.0, 70.0);
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
