//
//  HONCallingCodeViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/09/2014 @ 15:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONCallingCodeViewCell.h"


@interface HONCallingCodeViewCell ()
@property (nonatomic, strong) UIButton *toggledOnButton;
@property (nonatomic, strong) UIButton *toggledOffButton;
@end

@implementation HONCallingCodeViewCell
@synthesize countryVO = _countryVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self hideChevron];
	}
	
	return (self);
}

- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleSelected:(BOOL)isSelected {
	if (isSelected != _isSelected) {
		_isSelected = isSelected;
		
		if (_isSelected) {
			_toggledOnButton.hidden = NO;
			[UIView animateWithDuration:0.125 animations:^(void) {
				_toggledOnButton.alpha = 1.0;
			} completion:^(BOOL finished) {
				_toggledOffButton.hidden = YES;
			}];
			
		} else {
			_toggledOffButton.hidden = NO;
			[UIView animateWithDuration:0.25 animations:^(void) {
				_toggledOffButton.alpha = 1.0;
			} completion:^(BOOL finished) {
				_toggledOnButton.hidden = YES;
			}];
		}
	}
}

- (void)setCountryVO:(HONCountryVO *)countryVO {
	_countryVO = countryVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 15.0, 180.0, 18.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	nameLabel.textColor = [UIColor blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _countryVO.countryName;
	[self.contentView addSubview:nameLabel];
	
	UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 33.0, 50.0, 15.0)];
	codeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	codeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	codeLabel.backgroundColor = [UIColor clearColor];
	codeLabel.text = [@"+" stringByAppendingString:_countryVO.callingCode];
	[self.contentView addSubview:codeLabel];
	
	_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_toggledOnButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
	[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
	[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
	[_toggledOnButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
	_toggledOnButton.hidden = !_isSelected;
	[self.contentView addSubview:_toggledOnButton];
	
	_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_toggledOffButton.frame = _toggledOnButton.frame;
	[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
	[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
	[_toggledOffButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:_toggledOffButton];
}


#pragma mark - Navigation
- (void)_goDeselect {
	_isSelected = NO;
	
	_toggledOffButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOffButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_toggledOnButton.hidden = YES;
		
		if ([self.delegate respondsToSelector:@selector(callingCodeViewCell:didDeselectCountry:)])
			[self.delegate callingCodeViewCell:self didDeselectCountry:_countryVO];
	}];
}

- (void)_goSelect {
	_isSelected = YES;
	
	_toggledOnButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_toggledOffButton.hidden = YES;
		
		if ([self.delegate respondsToSelector:@selector(callingCodeViewCell:didSelectCountry:)])
			[self.delegate callingCodeViewCell:self didSelectCountry:_countryVO];
	}];
}

@end
