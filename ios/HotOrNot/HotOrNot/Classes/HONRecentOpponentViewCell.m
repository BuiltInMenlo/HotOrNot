//
//  HONRecentOpponentViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONRecentOpponentViewCell.h"
#import "HONUserVO.h"

@interface HONRecentOpponentViewCell ()
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *checkButton;
@end

@implementation HONRecentOpponentViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsInviteUser:(BOOL)isInvite {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(198.0, 10.0, 104.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(248.0 - ((int)(isInvite) * 50.0), 10.0, 44.0 + ((int)(isInvite) * 60.0), 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:(isInvite) ? @"subscribe_nonActive" : @"addFriendPlus_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:(isInvite) ? @"subscribe_Active" : @"addFriendPlus_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
	}
	
	return (self);
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(266.0, 9.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(258.0, 9.0, 44.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"addFriendPlus_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"addFriendPlus_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 20.0, 200.0, 22.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:17];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:nameLabel];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.hidden = isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goFollow {
	_followButton.hidden = YES;
	_checkButton.hidden = NO;
	
	[self.delegate recentOpponentViewCell:self user:_userVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	_checkButton.hidden = YES;
	
	[self.delegate recentOpponentViewCell:self user:_userVO toggleSelected:NO];
}

@end
