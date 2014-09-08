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


#define TOP_TINT_COLOR		[UIColor colorWithRed:0.009f green:0.910 blue:0.178f alpha:0.500f]
#define BOT_TINT_COLOR		[UIColor colorWithRed:0.009f green:0.910 blue:0.178f alpha:0.333f]

#define TINT_FADE_DURATION		0.250f
#define TINT_TIMER_DURATION		0.333f


@interface HONUserToggleViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONUserToggleViewCell
@synthesize delegate = _delegate;
@synthesize contactUserVO = _contactUserVO;
@synthesize trivialUserVO = _trivialUserVO;

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
		
		_isSelected = NO;
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 22.0, 180.0, 18.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
		_nameLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
				
		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		//[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
		//[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:_toggledOffButton];
		
		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = _toggledOffButton.frame;
		//[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateNormal];
		//[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"chevron"] forState:UIControlStateHighlighted];
		_toggledOnButton.alpha = (int)_isSelected;
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
	_arrowImageView.hidden = !isEnabled;
	_scoreLabel.hidden = !isEnabled;
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
	
	NSString *nameCaption = [NSString stringWithFormat:@"Invite %@ to this app", _contactUserVO.fullName];
	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
	[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14] range:[nameCaption rangeOfString:_contactUserVO.fullName]];
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	NSLog(@":|: CELL >> TRIVIALUSER:[%@]", trivialUserVO.username);
	
	NSString *nameCaption = [_trivialUserVO.username stringByAppendingString:@" is…"];
	
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption];
	[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14] range:[nameCaption rangeOfString:_trivialUserVO.username]];
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
- (void)_loadAvatarImageFromPrefix:(NSString *)urlPrefix {
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		_contactUserVO.avatarImage = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		_avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder"];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urlPrefix stringByAppendingString:kSnapThumbSuffix]]
															  cachePolicy:kURLRequestCachePolicy
														  timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
}

@end
