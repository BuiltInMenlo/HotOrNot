//
//  HONNonAppContactViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONNonAppContactViewCell.h"

@interface HONNonAppContactViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation HONNonAppContactViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
		[self hideChevron];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(190.0, 0.0, 74.0, 64.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUninvite) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = _checkButton.frame;
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_inviteButton];
		
		UIButton *blockButton = [UIButton buttonWithType:UIButtonTypeCustom];
		blockButton.frame = CGRectMake(248.0, 0.0, 74.0, 64.0);
		[blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_nonActive"] forState:UIControlStateNormal];
		[blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_Active"] forState:UIControlStateHighlighted];
		[blockButton addTarget:self action:@selector(_goBlock) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:blockButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONContactUserVO *)userVO {
	_userVO = userVO;
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 8.0, 48.0, 48.0)];
	_avatarImageView.image = [UIImage imageNamed:@"defaultAvatarBackground"];
	[self.contentView addSubview:_avatarImageView];
	
	if (userVO.avatarImage != nil)
		_avatarImageView.image = userVO.avatarImage;
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 20.0, 195.0, 22.0)];;//[[UILabel alloc] initWithFrame:CGRectMake(13.0, 14.0, 240.0, 20.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.fullName;
	[self.contentView addSubview:nameLabel];
	
//	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 30.0, 240.0, 18.0)];
//	contactLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:15];
//	contactLabel.textColor = [[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.455];
//	contactLabel.backgroundColor = [UIColor clearColor];
//	contactLabel.text = (_userVO.isSMSAvailable) ? _userVO.rawNumber : _userVO.email;
//	[self.contentView addSubview:contactLabel];
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
		[self.delegate nonAppContactViewCell:self contactUser:_userVO toggleSelected:YES];
	}];
}

- (void)_goUninvite {
	_inviteButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_inviteButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
		[self.delegate nonAppContactViewCell:self contactUser:_userVO toggleSelected:NO];
	}];
}

- (void)_goBlock {
	
}


@end
