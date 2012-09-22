//
//  HONPopularUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserViewCell.h"
#import "UIImageView+WebCache.h"

@interface HONPopularUserViewCell()
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONPopularUserViewCell

@synthesize userImageView = _userImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize scoreLabel = _scoreLabel;

- (id)init {
	if ((self = [super init])) {
		self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
		self.userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.userImageView];
		
		self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 10.0, 200.0, 16.0)];
		//usernameLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//usernameLabel = [SNAppDelegate snLinkColor];
		self.usernameLabel.backgroundColor = [UIColor clearColor];
		self.usernameLabel.text = @"Username";
		[self addSubview:self.usernameLabel];
		
		self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 200.0, 16.0)];
		//scoreLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//scoreLabel = [SNAppDelegate snLinkColor];
		self.scoreLabel.backgroundColor = [UIColor clearColor];
		self.scoreLabel.text = @"#hashtag";
		[self addSubview:self.scoreLabel];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setUserVO:(HONPopularUserVO *)userVO {
	_userVO = userVO;
	
	[self.userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	self.usernameLabel.text = _userVO.username;
	self.scoreLabel.text = [NSString stringWithFormat:@"%d points", _userVO.score];
}
@end
