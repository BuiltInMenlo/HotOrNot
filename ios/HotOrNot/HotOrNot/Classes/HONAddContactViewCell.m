//
//  HONAddContactViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAddContactViewCell.h"

@interface HONAddContactViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *inviteButton;
@end

@implementation HONAddContactViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(212.0, 9.0, 104.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUninvite) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = CGRectMake(212.0, 9.0, 104.0, 44.0);
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_inviteButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONContactUserVO *)userVO {
	_userVO = userVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 14.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.fullName;
	[self addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 30.0, 180.0, 18.0)];
	contactLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	contactLabel.textColor = [HONAppDelegate honPercentGreyscaleColor:0.455];
	contactLabel.backgroundColor = [UIColor clearColor];
	contactLabel.text = (_userVO.isSMSAvailable) ? _userVO.rawNumber : _userVO.email;
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
	
	[self.delegate addContactViewCell:self user:_userVO toggleSelected:YES];
}

- (void)_goUninvite {
	_checkButton.hidden = YES;
	_inviteButton.hidden = NO;
	
	[self.delegate addContactViewCell:self user:_userVO toggleSelected:NO];
}

@end
