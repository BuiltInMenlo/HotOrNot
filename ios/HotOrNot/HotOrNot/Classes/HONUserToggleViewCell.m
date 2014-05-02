//
//  HONUserToggleViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/30/2014 @ 15:24 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONUserToggleViewCell.h"

@interface HONUserToggleViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *nameLabel;
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
		
		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = CGRectMake(239.0, 0.0, 64.0, 64.0);
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOnButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_toggledOnButton.hidden = YES;
		[self.contentView addSubview:_toggledOnButton];
		
		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = _toggledOnButton.frame;
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOffButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_toggledOffButton];
	}
	
	return (self);
}

- (void)invertSelected {
	_isSelected = !_isSelected;
	
	if (_isSelected) {
		_toggledOffButton.hidden = NO;
		[UIView animateWithDuration:0.125 animations:^(void) {
			_toggledOffButton.alpha = 1.0;
		} completion:^(BOOL finished) {
			_toggledOnButton.hidden = YES;
		}];
	
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_toggledOffButton.alpha = 0.0;
		} completion:^(BOOL finished) {
			_toggledOffButton.hidden = YES;
			[self.delegate userToggleViewCell:self didDeselectTrivialUser:_trivialUserVO];
		}];
	}
}

- (void)toggleSelected:(BOOL)isSelected {
	if (isSelected != _isSelected) {
		_isSelected = isSelected;
		
		if (_isSelected) {
			_toggledOffButton.hidden = NO;
			[UIView animateWithDuration:0.125 animations:^(void) {
				_toggledOffButton.alpha = 1.0;
			} completion:^(BOOL finished) {
				_toggledOnButton.hidden = YES;
			}];
		
		} else {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_toggledOffButton.alpha = 0.0;
			} completion:^(BOOL finished) {
				_toggledOffButton.hidden = YES;
			}];
		}
	}
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	if (_avatarImageView == nil) {
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0, 8.0, 48.0, 48.0)];
		[self.contentView addSubview:_avatarImageView];
	}
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_trivialUserVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		_avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_trivialUserVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];

	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	
	if (_arrowImageView == nil) {
		_arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"]];
		_arrowImageView.frame = CGRectOffset(_arrowImageView.frame, 4.0, 20.0);
		[self.contentView addSubview:_arrowImageView];
	
	} else
		_arrowImageView.image = [UIImage imageNamed:(trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"];
	
	if (trivialUserVO.isVerified) {
		_arrowImageView.frame = CGRectOffset(_arrowImageView.frame, -6.0, 0.0);
		
		UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 26.0, 25.0, 15.0)];
		scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		scoreLabel.textColor = (trivialUserVO.abuseCount < 0) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
		scoreLabel.backgroundColor = [UIColor clearColor];
		scoreLabel.text = [@"" stringFromInt:-trivialUserVO.abuseCount];
		[self.contentView addSubview:scoreLabel];
	
		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 60.0, 35.0);
		[self.contentView addSubview:verifiedImageView];
	}
	
	if (_nameLabel == nil) {
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0, 19.0, 195.0, 22.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.text = _trivialUserVO.username;
		[self.contentView addSubview:_nameLabel];
	}
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0, 8.0, 48.0, 48.0)];
	_avatarImageView.image = (_contactUserVO.avatarImage != nil) ? _contactUserVO.avatarImage : [UIImage imageNamed:@"avatarPlaceholder"];
	[self.contentView addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	_arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unverifiedUserArrow"]];
	_arrowImageView.frame = CGRectOffset(_arrowImageView.frame, 4.0, 20.0);
	[self.contentView addSubview:_arrowImageView];
	
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0, 19.0, 195.0, 22.0)];
	_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
	_nameLabel.textColor = [UIColor blackColor];
	_nameLabel.backgroundColor = [UIColor clearColor];
	_nameLabel.text = _contactUserVO.fullName;
	[self.contentView addSubview:_nameLabel];
}


#pragma mark - Navigation
- (void)_goDeselect {
	_toggledOffButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOffButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_toggledOnButton.hidden = YES;
		
		if (_trivialUserVO != nil)
			[self.delegate userToggleViewCell:self didDeselectTrivialUser:_trivialUserVO];
		
		else
			[self.delegate userToggleViewCell:self didDeselectContactUser:_contactUserVO];
	}];
}

- (void)_goSelect {
	_toggledOnButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_toggledOffButton.hidden = YES;
		
		if (self.trivialUserVO != nil)
			[self.delegate userToggleViewCell:self didSelectTrivialUser:_trivialUserVO];
		
		else
			[self.delegate userToggleViewCell:self didSelectContactUser:_contactUserVO];
	}];
}

@end
