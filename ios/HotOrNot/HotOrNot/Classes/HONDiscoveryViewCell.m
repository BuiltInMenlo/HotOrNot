//
//  HONDiscoveryViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONDiscoveryViewCell.h"
#import "HONImageLoadingView.h"

@interface HONDiscoveryViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation HONDiscoveryViewCell
@synthesize delegate = _delegate;
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
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(11.0, 0.0, kSnapMediumDim * 2.0, kSnapMediumDim)];
	holderView.clipsToBounds = YES;
	[self addSubview:holderView];
	
	HONImageLoadingView *lImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0, 4.0)];
	[holderView addSubview:lImageLoadingView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.creatorVO.imagePrefix]] placeholderImage:nil];
	[holderView addSubview:lImageView];
	
	HONImageLoadingView *rImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0 + kSnapMediumDim, 4.0)];
	[holderView addSubview:rImageLoadingView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSnapMediumDim, 0.0, kSnapMediumDim, kSnapMediumDim)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_lChallengeVO.challengers lastObject]).imagePrefix]] placeholderImage:nil];
	[holderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 83.0, 140.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _lChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	
	UIButton *txtSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	txtSelectButton.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y - 10.0, subjectLabel.frame.size.width, subjectLabel.frame.size.height + 20.0);
	[txtSelectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:txtSelectButton];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = holderView.frame;
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelectLeft) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}

- (void)setRChallengeVO:(HONChallengeVO *)rChallengeVO {
	_rChallengeVO = rChallengeVO;
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(162.0, 0.0, kSnapMediumDim * 2.0, kSnapMediumDim)];
	holderView.clipsToBounds = YES;
	[self addSubview:holderView];
		
	HONImageLoadingView *lImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0, 4.0)];
	[holderView addSubview:lImageLoadingView];

	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.creatorVO.imagePrefix]] placeholderImage:nil];
	[holderView addSubview:lImageView];
	
	HONImageLoadingView *rImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0 + kSnapMediumDim, 4.0)];
	[holderView addSubview:rImageLoadingView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSnapMediumDim, 0.0, kSnapMediumDim, kSnapMediumDim)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_rChallengeVO.challengers lastObject]).imagePrefix]] placeholderImage:nil];
	[holderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(164.0, 83.0, 140.0, 20.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _rChallengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	
	UIButton *txtSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	txtSelectButton.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y - 10.0, subjectLabel.frame.size.width, subjectLabel.frame.size.height + 20.0);
	[txtSelectButton addTarget:self action:@selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:txtSelectButton];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = holderView.frame;
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelectRight) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:selectButton];
}


#pragma mark - Navigation
- (void)_goSelectLeft {
	[self.delegate discoveryViewCell:self selectLeftChallenge:_lChallengeVO];
}

- (void)_goSelectRight {
	[self.delegate discoveryViewCell:self selectRightChallenge:_rChallengeVO];
}

#pragma mark - UI Presentation
- (void)didSelectLeftChallenge {
	[self performSelector:@selector(_resetBGLeft) withObject:nil afterDelay:0.33];
}

- (void)didSelectRightChallenge {
	[self performSelector:@selector(_resetBGRight) withObject:nil afterDelay:0.33];
}

- (void)_resetBGLeft {
}

- (void)_resetBGRight {
}

@end
