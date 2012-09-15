//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteItemViewCell.h"
#import "EGOImageView.h"

@interface HONVoteItemViewCell()
@property (nonatomic, strong) EGOImageView *mainImgView;
@property (nonatomic, strong) EGOImageView *subImgView;
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
		
		self.mainImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 155.0, 300.0)];
		self.mainImgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.mainImgView];
		
		self.mainImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.mainImgButton.frame = self.mainImgView.frame;
		[self.mainImgButton setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
		[self.mainImgButton addTarget:self action:@selector(_goMainVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.mainImgButton];
		
		self.subImgView = [[EGOImageView alloc] initWithFrame:CGRectMake(165.0, 5.0, 155.0, 300.0)];
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
	
	self.mainImgView.imageURL = [NSURL URLWithString:challengeVO.imageURL];
	self.subImgView.imageURL = [NSURL URLWithString:challengeVO.image2URL];
	
	[self.mainImgButton setTitle:[NSString stringWithFormat:@"%d", (arc4random() % 10)] forState:UIControlStateNormal];
	[self.subImgButton setTitle:[NSString stringWithFormat:@"%d", (arc4random() % 10)] forState:UIControlStateNormal];
}


#pragma mark - Navigation
- (void)_goMainVote {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MAIN" object:self.challengeVO];
}

- (void)_goSubVote {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_SUB" object:self.challengeVO];
}

@end
