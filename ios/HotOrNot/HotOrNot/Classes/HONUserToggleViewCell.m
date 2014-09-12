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


@property (nonatomic, strong) UIFont *nameLabelFont;
@end


const CGFloat kEmojiCellFontSize = 51.0f;
const CGFloat kEmojiCellFontSpacing = 3.0f;

@implementation HONUserToggleViewCell
@synthesize delegate = _delegate;
@synthesize contactUserVO = _contactUserVO;
@synthesize trivialUserVO = _trivialUserVO;
@synthesize clubVO = _clubVO;

- (id)init {
	if ((self = [super init])) {
		_isSelected = NO;
		
		_nameLabelFont =[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 22.0, 220.0, 18.0)];
		_nameLabel.font = _nameLabelFont;
		//_nameLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 7.5, 220.0, kEmojiCellFontSize)]; //y = 6.0
		_emojiLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:kEmojiCellFontSize];
		_emojiLabel.textColor = [UIColor blackColor];
		_emojiLabel.text = @"";
		[self.contentView addSubview:_emojiLabel];
				
		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateNormal];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateHighlighted];
		[_toggledOffButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		_toggledOffButton.hidden = YES;
		[self.contentView addSubview:_toggledOffButton];
		
		
		
		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = _toggledOffButton.frame;
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateNormal];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateHighlighted];
		[_toggledOffButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_toggledOnButton.alpha = (int)_isSelected;
		_toggledOnButton.hidden = YES;
		[self.contentView addSubview:_toggledOnButton];
		
		
		
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
	
	//NSLog(@"CONTACT_USER:[%@]", _contactUserVO.dictionary);
	
	NSString *nameCaption = _contactUserVO.fullName;//[NSString stringWithFormat:@"Invite %@ to this app", _contactUserVO.fullName];
	_nameLabel.font = _nameLabelFont;
	_nameLabel.text = nameCaption;
//	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
//	[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14] range:[nameCaption rangeOfString:_contactUserVO.fullName]];
	
		CGSize size = [[nameCaption stringByAppendingString:@"   "] boundingRectWithSize:_nameLabel.frame.size
											options:NSStringDrawingTruncatesLastVisibleLine
										 attributes:@{NSFontAttributeName:_nameLabelFont}
											context:nil].size;
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, MIN(size.width, _nameLabel.frame.size.width), _nameLabel.frame.size.height);
	_emojiLabel.frame = CGRectMake((_nameLabel.frame.origin.x + _nameLabel.frame.size.width) + 5.0, _emojiLabel.frame.origin.y, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
	[self hideChevron];
	
	_toggledOffButton.hidden = NO;
	_toggledOnButton.hidden = NO;
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	//NSLog(@"TRIVIAL_USER:[%@]", _trivialUserVO.dictionary);
	
	
//	_trivialUserVO.username = (_trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me" : _trivialUserVO.username;
	NSString *nameCaption = (_trivialUserVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @"Me " : _trivialUserVO.username;//[NSString stringWithFormat:@"%@ is…", _trivialUserVO.username];
	
//	_nameLabel.textColor = [UIColor blackColor];
//	_nameLabel.font = _nameLabelFont;
	_nameLabel.text = nameCaption;
	
	CGSize size = [_nameLabel.text boundingRectWithSize:_nameLabel.frame.size
											options:NSStringDrawingTruncatesLastVisibleLine
										 attributes:@{NSFontAttributeName:_nameLabel.font}
											context:nil].size;
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, MIN(size.width, 220.0), _nameLabel.frame.size.height);
	_emojiLabel.frame = CGRectMake((_nameLabel.frame.origin.x + _nameLabel.frame.size.width) + 5.0, _emojiLabel.frame.origin.y, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
	//[self hideChevron];
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
	//NSLog(@"CLUB:[%@]", _clubVO.dictionary);
	
	_clubPhotoVO = (HONClubPhotoVO *)[_clubVO.submissions firstObject];
	
	_nameLabel.text = ([_clubVO.clubName isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"username"]]) ? @"Me" : _clubVO.clubName;
	
	NSString *emojis = @"";
	for (NSString *emoji in _clubPhotoVO.subjectNames) {
		//NSLog(@"SUBJECT.LEN:[%u / %u / %u / %u] (%@)", [emoji length], [emoji lengthOfBytesUsingEncoding:NSUTF16StringEncoding], [emoji lengthOfBytesUsingEncoding:NSUTF32StringEncoding], [emoji lengthOfBytesUsingEncoding:NSUTF32BigEndianStringEncoding], emoji);
		emojis = [emojis stringByAppendingString:emoji];
	}
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:emojis];
	
	[attributedString addAttribute:NSFontAttributeName
							 value:_emojiLabel.font
							 range:NSMakeRange(0, [emojis length])];
	
	[attributedString addAttribute:NSKernAttributeName
							 value:[NSNumber numberWithFloat:kEmojiCellFontSpacing]
							 range:NSMakeRange(0, [emojis length])];
	
	_emojiLabel.frame = CGRectMake(_emojiLabel.frame.origin.x, _emojiLabel.frame.origin.y, (kEmojiCellFontSize + kEmojiCellFontSpacing) * ([emojis length] * 1.0), _emojiLabel.frame.size.height);
	_emojiLabel.attributedText = attributedString;
	[self hideChevron];
}


#pragma mark - Navigation
- (void)_goDeselect {
	_isSelected = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didDeselectContactUser:)])
			[self.delegate userToggleViewCell:self didDeselectContactUser:_contactUserVO];
	}];
}

- (void)_goSelect {
	_isSelected = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(userToggleViewCell:didSelectContactUser:)])
			[self.delegate userToggleViewCell:self didSelectContactUser:_contactUserVO];
	}];}

@end
