//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteItemViewCell.h"
#import "UIImageView+WebCache.h"


@interface HONVoteItemViewCell()
@property (nonatomic, strong) UIImageView *mainImgView;
@property (nonatomic, strong) UIImageView *subImgView;
@property (nonatomic, strong) UIButton *mainImgButton;
@property (nonatomic, strong) UIButton *subImgButton;
@property (nonatomic, strong) UILabel *mainImgLabel;
@property (nonatomic, strong) UILabel *subImgLabel;

@end

@implementation HONVoteItemViewCell

@synthesize mainImgView = _mainImgView;
@synthesize subImgView = _subImgView;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		self.mainImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 155.0, 180.0)];
		self.mainImgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.mainImgView];
		
		self.mainImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.mainImgButton.frame = self.mainImgView.frame;
		[self.mainImgButton setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
		[self.mainImgButton addTarget:self action:@selector(_goMainVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.mainImgButton];
		
		self.subImgView = [[UIImageView alloc] initWithFrame:CGRectMake(165.0, 5.0, 155.0, 180.0)];
		self.subImgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.subImgView];
		
		self.subImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.subImgButton.frame = self.subImgView.frame;
		[self.subImgButton setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
		[self.subImgButton addTarget:self action:@selector(_goSubVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.subImgButton];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[self.mainImgView setImageWithURL:[NSURL URLWithString:challengeVO.imageURL] placeholderImage:nil options:SDWebImageProgressiveDownload];
	[self.subImgView setImageWithURL:[NSURL URLWithString:challengeVO.image2URL] placeholderImage:nil options:SDWebImageProgressiveDownload];
		
	[self.mainImgButton setTitle:[NSString stringWithFormat:@"%d", challengeVO.scoreCreator] forState:UIControlStateNormal];
	[self.subImgButton setTitle:[NSString stringWithFormat:@"%d", challengeVO.scoreChallenger] forState:UIControlStateNormal];
}


#pragma mark - Navigation
- (void)_goMainVote {
	[self.mainImgButton setTitle:[NSString stringWithFormat:@"%d", (self.challengeVO.scoreCreator + 1)] forState:UIControlStateNormal];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MAIN" object:self.challengeVO];
}

- (void)_goSubVote {
	[self.subImgButton setTitle:[NSString stringWithFormat:@"%d", (self.challengeVO.scoreChallenger + 1)] forState:UIControlStateNormal];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_SUB" object:self.challengeVO];
}

@end
