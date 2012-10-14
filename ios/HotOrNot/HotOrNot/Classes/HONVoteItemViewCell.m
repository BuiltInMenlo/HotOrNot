//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteItemViewCell.h"
#import "UIImageView+WebCache.h"

#import "HONAppDelegate.h"


@interface HONVoteItemViewCell()
@property (nonatomic, strong) UIImageView *lHolderImgView;
@property (nonatomic, strong) UIImageView *rHolderImgView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UIButton *lVoteButton;
@property (nonatomic, strong) UIButton *rVoteButton;
@end

@implementation HONVoteItemViewCell

@synthesize lHolderImgView = _lHolderImgView;
@synthesize rHolderImgView = _rHolderImgView;
@synthesize lScoreLabel = _lScoreLabel;
@synthesize rScoreLabel = _rScoreLabel;
@synthesize lVoteButton = _lVoteButton;
@synthesize rVoteButton = _rVoteButton;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		_lHolderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 154.0, 249.0)];
		_lHolderImgView.image = [UIImage imageNamed:@"voteBackgroundLiked_nonActive.png"];
		_lHolderImgView.userInteractionEnabled = YES;
		[self addSubview:_lHolderImgView];
		
		_rHolderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_lHolderImgView.frame.origin.x + _lHolderImgView.frame.size.width, 5.0, 154.0, 249.0)];
		_rHolderImgView.image = [UIImage imageNamed:@"RvoteBackgroundLiked_nonActive.png"];
		_rHolderImgView.userInteractionEnabled = YES;
		[self addSubview:_rHolderImgView];
		
		_lVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lVoteButton.frame = CGRectMake(5.0, 208.0, 147.0, 35.0);
		[_lVoteButton addTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
		[_lHolderImgView addSubview:_lVoteButton];
		
		_rVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_rVoteButton.frame = CGRectMake(0.0, 208.0, 147.0, 35.0);
		[_rVoteButton addTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
		[_rHolderImgView addSubview:_rVoteButton];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UIView *lHolderView = [[UIView alloc] initWithFrame:CGRectMake(15.0, 10.0, 125.0, 180.0)];
	lHolderView.clipsToBounds = YES;
	[_lHolderImgView addSubview:lHolderView];
	
	UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lHolderView.frame.size.width * -0.5, 0.0, kMediumW, kMediumH)];
	[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
	lImgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
	[lHolderView addSubview:lImgView];
	
	UIButton *lZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	lZoomButton.frame = lImgView.frame;
	[lZoomButton addTarget:self action:@selector(_goLeftZoom) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderImgView addSubview:lZoomButton];
	
	UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, 50.0, 84.0, 84.0)];
	lScoreImgView.image = [UIImage imageNamed:@"overlayBackgroundScore.png"];
	[_lHolderImgView addSubview:lScoreImgView];
	
	_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 84.0, 16.0)];
	//_lScoreLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	_lScoreLabel.backgroundColor = [UIColor clearColor];
	_lScoreLabel.textColor = [UIColor whiteColor];
	_lScoreLabel.textAlignment = NSTextAlignmentCenter;
	_lScoreLabel.text = [NSString stringWithFormat:@"%d", challengeVO.scoreCreator];
	[lScoreImgView addSubview:_lScoreLabel];
	
	UIView *rHolderView = [[UIView alloc] initWithFrame:CGRectMake(15.0, 10.0, 125.0, 180.0)];
	rHolderView.clipsToBounds = YES;
	[_rHolderImgView addSubview:rHolderView];
	
	UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rHolderView.frame.size.width * -0.5, 0.0, kMediumW, kMediumH)];
	[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.image2URL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
	rImgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
	[rHolderView addSubview:rImgView];
	
	UIButton *rZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rZoomButton.frame = rImgView.frame;
	[rZoomButton addTarget:self action:@selector(_goRightZoom) forControlEvents:UIControlEventTouchUpInside];
	[_rHolderImgView addSubview:rZoomButton];
	
	UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, 50.0, 84.0, 84.0)];
	rScoreImgView.image = [UIImage imageNamed:@"overlayBackgroundScore.png"];
	[_rHolderImgView addSubview:rScoreImgView];
	
	_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 84.0, 16.0)];
	//_rScoreLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	_rScoreLabel.backgroundColor = [UIColor clearColor];
	_rScoreLabel.textColor = [UIColor whiteColor];
	_rScoreLabel.textAlignment = NSTextAlignmentCenter;
	_rScoreLabel.text = [NSString stringWithFormat:@"%d", challengeVO.scoreChallenger];
	[rScoreImgView addSubview:_rScoreLabel];
	
		
//	[self.mainImgButton setTitle:[NSString stringWithFormat:@"%d", challengeVO.scoreCreator] forState:UIControlStateNormal];
//	[self.subImgButton setTitle:[NSString stringWithFormat:@"%d", challengeVO.scoreChallenger] forState:UIControlStateNormal];
}


#pragma mark - Navigation
- (void)_goLeftVote {
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	
	_lHolderImgView.image = [UIImage imageNamed:@"voteBackgroundLiked_Active.png"];
	_lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreCreator + 1)];
	
	UIImageView *losingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 13.0, 128.0, 180.0)];
	losingImgView.image = [UIImage imageNamed:@"voteOverlay.png"];
	[_rHolderImgView addSubview:losingImgView];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MAIN" object:self.challengeVO];
}

- (void)_goRightVote {
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	
	_rHolderImgView.image = [UIImage imageNamed:@"RvoteBackgroundLiked_Active.png"];
	_rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreChallenger + 1)];
	
	UIImageView *losingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 13.0, 128.0, 180.0)];
	losingImgView.image = [UIImage imageNamed:@"voteOverlay.png"];
	[_lHolderImgView addSubview:losingImgView];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_SUB" object:self.challengeVO];
}

- (void)_goLeftZoom {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOM_IMAGE" object:self.challengeVO.imageURL];
}

- (void)_goRightZoom {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOM_IMAGE" object:self.self.challengeVO.image2URL];
}

@end
