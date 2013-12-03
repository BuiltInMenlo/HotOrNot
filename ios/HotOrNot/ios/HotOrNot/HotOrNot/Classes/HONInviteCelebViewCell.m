//
//  HONInviteCelebViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.27.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONInviteCelebViewCell.h"

@interface HONInviteCelebViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *inviteButton;
@end

@implementation HONInviteCelebViewCell
@synthesize delegate = _delegate;
@synthesize celebVO = _celebVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(266.0, 9.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUninvite) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = CGRectMake(259.0, 9.0, 44.0, 44.0);
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"emailButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"emailButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_inviteButton];
	}
	
	return (self);
}

- (void)setCelebVO:(HONCelebVO *)celebVO {
	_celebVO = celebVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_celebVO.avatarURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 15.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _celebVO.fullName;
	[self addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 31.0, 180.0, 18.0)];
	contactLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	contactLabel.textColor = [HONAppDelegate honPercentGreyscaleColor:0.455];
	contactLabel.backgroundColor = [UIColor clearColor];
	contactLabel.text = [NSString stringWithFormat:@"@%@", _celebVO.username];
	[self addSubview:contactLabel];
}


- (void)toggleSelected:(BOOL)isSelected {
	_inviteButton.hidden = isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goInvite {
	_checkButton.hidden = NO;
	_inviteButton.hidden = YES;
	
	[self.delegate inviteCelebViewCell:self celeb:_celebVO toggleSelected:YES];
}

- (void)_goUninvite {
	_checkButton.hidden = YES;
	_inviteButton.hidden = NO;
	
	[self.delegate inviteCelebViewCell:self celeb:_celebVO toggleSelected:NO];
}

@end
