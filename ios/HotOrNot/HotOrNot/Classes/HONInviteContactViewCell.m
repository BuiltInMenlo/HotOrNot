//
//  HONInviteContactViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteContactViewCell.h"


@interface HONInviteContactViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *inviteButton;
@end

@implementation HONInviteContactViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUninvite) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = _checkButton.frame;
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_inviteButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONContactUserVO *)userVO {
	_userVO = userVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 14.0, 180.0, 20.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.fullName;
	[self.contentView addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 30.0, 180.0, 18.0)];
	contactLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:15];
	contactLabel.textColor = [[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.455];
	contactLabel.backgroundColor = [UIColor clearColor];
	contactLabel.text = (_userVO.isSMSAvailable) ? _userVO.rawNumber : _userVO.email;
	[self.contentView addSubview:contactLabel];
}


- (void)toggleSelected:(BOOL)isSelected {
	_inviteButton.alpha = (int)!isSelected;
	_inviteButton.hidden = isSelected;
	
	_checkButton.alpha = (int)isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goInvite {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_inviteButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_inviteButton.hidden = YES;
		[self.delegate inviteContactViewCell:self inviteUser:_userVO toggleSelected:YES];
	}];
}

- (void)_goUninvite {
	_inviteButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_inviteButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
		[self.delegate inviteContactViewCell:self inviteUser:_userVO toggleSelected:NO];
	}];
}

@end
