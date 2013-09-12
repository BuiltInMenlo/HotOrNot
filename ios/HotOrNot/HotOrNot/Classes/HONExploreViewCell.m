//
//  HONExploreViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.07.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONExploreViewCell.h"
#import "HONImageLoadingView.h"

@interface HONExploreViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation HONExploreViewCell
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
	
	//NSLog(@"L-CHALLENGE:(%d)[%@]", _lChallengeVO.challengeID, [_lChallengeVO.dictionary objectForKey:@"challengers"]);
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 75.0 * 2.0, 75.0)];
	holderView.clipsToBounds = YES;
	[self addSubview:holderView];
	
	HONImageLoadingView *lImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0, 4.0)];
	[holderView addSubview:lImageLoadingView];
	
	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 75.0, 75.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _lChallengeVO.creatorVO.imagePrefix]] placeholderImage:nil];
	[holderView addSubview:lImageView];
	
	HONImageLoadingView *rImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0 + 75.0, 4.0)];
	[holderView addSubview:rImageLoadingView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 0.0, 75.0, 75.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_lChallengeVO.challengers objectAtIndex:0]).imagePrefix]] placeholderImage:nil];
	[holderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 89.0, 140.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
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
	
	//NSLog(@"R-CHALLENGE:(%d)[%@]", _rChallengeVO.challengeID, [_rChallengeVO.dictionary objectForKey:@"challengers"]);
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 10.0, 75.0 * 2.0, 75.0)];
	holderView.clipsToBounds = YES;
	[self addSubview:holderView];
		
	HONImageLoadingView *lImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0, 4.0)];
	[holderView addSubview:lImageLoadingView];

	UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 75.0, 75.0)];
	[lImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", _rChallengeVO.creatorVO.imagePrefix]] placeholderImage:nil];
	[holderView addSubview:lImageView];
	
	HONImageLoadingView *rImageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(4.0 + 75.0, 4.0)];
	[holderView addSubview:rImageLoadingView];
	
	UIImageView *rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 0.0, 75.0, 75.0)];
	[rImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_rChallengeVO.challengers objectAtIndex:0]).imagePrefix]] placeholderImage:nil];
	[holderView addSubview:rImageView];
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 89.0, 140.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
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
