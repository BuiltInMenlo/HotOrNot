//
//  HONUserToggleViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/30/2014 @ 15:24 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UILabel+FormattedText.h"
#import <AddressBook/AddressBook.h>

#import "HONUserToggleViewCell.h"
#import "HONClubPhotoVO.h"



@interface HONUserToggleViewCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) HONClubPhotoVO *clubPhotoVO;
@end

@implementation HONUserToggleViewCell
@synthesize delegate = _delegate;
@synthesize contactUserVO = _contactUserVO;
@synthesize trivialUserVO = _trivialUserVO;
@synthesize clubVO = _clubVO;

- (id)init {
	if ((self = [super init])) {
		_isSelected = NO;
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 22.0, 220.0, 18.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:14];
		//_nameLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 11.0, 220.0, 42.0)];
		_emojiLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:42];
		_emojiLabel.textColor = [UIColor blackColor];
		//_emojiLabel.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
		_emojiLabel.text = @"";
		[self.contentView addSubview:_emojiLabel];
				
//		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_toggledOffButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
//		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
//		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateHighlighted];
//		[self.contentView addSubview:_toggledOffButton];
		
//		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_toggledOnButton.frame = _toggledOffButton.frame;
//		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
//		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateHighlighted];
//		_toggledOnButton.alpha = (int)_isSelected;
//		[self.contentView addSubview:_toggledOnButton];
	}
	
	return (self);
}

- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleUI:(BOOL)isEnabled {
	_toggledOffButton.hidden = !isEnabled;
	_toggledOnButton.hidden = !isEnabled;
	_nameLabel.hidden = !isEnabled;
	_emojiLabel.hidden = !isEnabled;
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = (int)isSelected;
	} completion:^(BOOL finished) {
	}];
}

- (void)toggleOnWithReset:(BOOL)isReset {
	_isSelected = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = _isSelected;
	} completion:^(BOOL finished) {
		if (isReset)
			_toggledOnButton.alpha = 0.0;
			
	}];
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	NSString *nameCaption = _contactUserVO.fullName;//[NSString stringWithFormat:@"Invite %@ to this app", _contactUserVO.fullName];
	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
	[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14] range:[nameCaption rangeOfString:_contactUserVO.fullName]];
	
	CGSize size = [nameCaption boundingRectWithSize:_nameLabel.frame.size
											options:NSStringDrawingTruncatesLastVisibleLine
										 attributes:@{NSFontAttributeName:_nameLabel.font}
											context:nil].size;
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, MIN(size.width, _nameLabel.frame.size.width), _nameLabel.frame.size.height);
	_emojiLabel.frame = CGRectMake((_nameLabel.frame.origin.x + _nameLabel.frame.size.width) + 5.0, _emojiLabel.frame.origin.y, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	NSString *nameCaption = _trivialUserVO.username;//[NSString stringWithFormat:@"%@ is…", _trivialUserVO.username];
	
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption];
	[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14] range:[nameCaption rangeOfString:_trivialUserVO.username]];
	
	CGSize size = [nameCaption boundingRectWithSize:_nameLabel.frame.size
											options:NSStringDrawingTruncatesLastVisibleLine
										 attributes:@{NSFontAttributeName:_nameLabel.font}
											context:nil].size;
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, MIN(size.width, 220.0), _nameLabel.frame.size.height);
	_emojiLabel.frame = CGRectMake((_nameLabel.frame.origin.x + _nameLabel.frame.size.width) + 5.0, _emojiLabel.frame.origin.y, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
	
	[self hideChevron];
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	_clubPhotoVO = (HONClubPhotoVO *)[_clubVO.submissions firstObject];
	
	
	NSString *emojis = @"";
	for (NSString *emoji in _clubPhotoVO.subjectNames) {
		emojis = [emojis stringByAppendingString:emoji];
	}
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:emojis];
	
	[attributedString addAttribute:NSFontAttributeName
							 value:_emojiLabel.font
							 range:NSMakeRange(0, [emojis length])];
	
	[attributedString addAttribute:NSKernAttributeName
							 value:[NSNumber numberWithFloat:5.0]
							 range:NSMakeRange(0, [emojis length])];
	
	_emojiLabel.frame = CGRectMake(_emojiLabel.frame.origin.x, _emojiLabel.frame.origin.y, _emojiLabel.font.pointSize * [emojis length], _emojiLabel.frame.size.height);
	_emojiLabel.attributedText = attributedString;
}


#pragma mark - Navigation
- (void)_goDeselectContactUser {
	_isSelected = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didDeselectContactUser:)])
			[self.delegate userToggleViewCell:self didDeselectContactUser:_contactUserVO];
	}];
}

- (void)_goDeselectTrivialUser {
	_isSelected = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didDeselectTrivialUser:)])
			[self.delegate userToggleViewCell:self didDeselectTrivialUser:_trivialUserVO];
	}];
}


- (void)_goSelectContactUser {
	_isSelected = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didDeselectContactUser:)])
			[self.delegate userToggleViewCell:self didSelectContactUser:_contactUserVO];
	}];
}

- (void)_goSelectTrivalUser {
	_isSelected = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didDeselectTrivialUser:)])
			[self.delegate userToggleViewCell:self didSelectTrivialUser:_trivialUserVO];
	}];
}

- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(userToggleViewCell:showProfileForTrivialUser:)])
		[self.delegate userToggleViewCell:self showProfileForTrivialUser:_trivialUserVO];
}


#pragma mark - UI Presentation


@end
