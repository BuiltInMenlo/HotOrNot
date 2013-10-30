//
//  HONFollowUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 6:55 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONFollowUserViewCell.h"

@interface HONFollowUserViewCell ()
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *checkButton;
@end

@implementation HONFollowUserViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(198.0, 11.0, 104.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = CGRectMake(198.0, 11.0, 104.0, 44.0);
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_followButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	NSMutableString *avatarURL = [_userVO.avatarURL mutableCopy];
	[avatarURL replaceOccurrencesOfString:@"Large_640x1136" withString:@"Small_160x160.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 22.0, 130.0, 22.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
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
	
	[self.delegate followViewCell:self user:_userVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	_checkButton.hidden = YES;
	
	[self.delegate followViewCell:self user:_userVO toggleSelected:NO];
}


@end