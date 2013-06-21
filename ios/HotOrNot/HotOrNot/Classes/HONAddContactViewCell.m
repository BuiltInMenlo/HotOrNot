//
//  HONAddContactViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAddContactViewCell.h"
#import "HONAppDelegate.h"

@interface HONAddContactViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *inviteButton;
@end

@implementation HONAddContactViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(266.0, 9.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"viewedSnapCheck"] forState:UIControlStateHighlighted];
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

- (void)setUserVO:(HONContactUserVO *)userVO {
	_userVO = userVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 15.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.fullName;
	[self addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 31.0, 180.0, 18.0)];
	contactLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	contactLabel.textColor = [HONAppDelegate honGrey455Color];
	contactLabel.backgroundColor = [UIColor clearColor];
	contactLabel.text = (_userVO.isSMSAvailable) ? _userVO.mobileNumber : _userVO.email;
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
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_CONTACT_INVITE" object:_userVO];
}

- (void)_goUninvite {
	_checkButton.hidden = YES;
	_inviteButton.hidden = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DROP_CONTACT_INVITE" object:_userVO];
}

@end
