//
//  HONUserToggleViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/30/2014 @ 15:24 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

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

@property (nonatomic, strong) UIView *overlayTintView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic) BOOL isTintCycleFull;
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
		_isTintCycleFull = NO;
		
		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 8.0, 48.0, 48.0)];
		[self.contentView addSubview:_avatarImageView];
		
		[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"thumbMask"]];
		
		_avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_avatarButton.frame = _avatarImageView.frame;
		[self.contentView addSubview:_avatarButton];
			
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 22.0, 180.0, 18.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unverifiedUserArrow"]];
		_arrowImageView.frame = CGRectOffset(_arrowImageView.frame, 64.0, 28.0);
		_arrowImageView.hidden = YES;
		[self.contentView addSubview:_arrowImageView];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(83.0, 33.0, 25.0, 15.0)];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_scoreLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.hidden = YES;
		_scoreLabel.text = @"0";
		[self.contentView addSubview:_scoreLabel];
		
		
		_overlayTintView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight)];
		_overlayTintView.backgroundColor = BOT_TINT_COLOR;
		//[self.contentView addSubview:_overlayTintView];
		
		
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
		
		//[self _toggleTintCycle:_isSelected];
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
		
		//[self _toggleTintCycle:_isSelected];
	}
}

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	
	[self _loadAvatarImageFromPrefix:_trivialUserVO.avatarPrefix];
	[_avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	
	_arrowImageView.image = [UIImage imageNamed:(_trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"];
	_arrowImageView.hidden = NO;
	
	_scoreLabel.textColor = (_trivialUserVO.abuseCount < 0) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
	_scoreLabel.text = [@"" stringFromInt:-_trivialUserVO.abuseCount];
	_scoreLabel.hidden = NO;
	
//	if (trivialUserVO.isVerified) {
//		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
//		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 45.0, 33.0);
//		verifiedImageView.hidden = !trivialUserVO.isVerified;
//		[self.contentView addSubview:verifiedImageView];
//	}
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	_avatarImageView.image = (_contactUserVO.avatarImage != nil) ? _contactUserVO.avatarImage : [UIImage imageNamed:@"avatarPlaceholder"];
	
	_nameLabel.text = (_contactUserVO.contactType == HONContactTypeUnmatched) ? _contactUserVO.fullName : _contactUserVO.username;
	
	if (_contactUserVO.contactType == HONContactTypeMatched) {
		[self _loadAvatarImageFromPrefix:_contactUserVO.avatarPrefix];
		[_avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
		
		_nameLabel.frame = CGRectOffset(_nameLabel.frame, 0.0, -9.0);
		
		_arrowImageView.image = [UIImage imageNamed:(_trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"];
		_arrowImageView.hidden = NO;
		
		
		
		_scoreLabel.textColor = (_trivialUserVO.abuseCount < 0) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
		_scoreLabel.text = [@"" stringFromInt:-_trivialUserVO.abuseCount];
		_scoreLabel.hidden = NO;
		
//		if (_trivialUserVO.isVerified) {
//			UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
//			verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 45.0, 33.0);
//			verifiedImageView.hidden = !_trivialUserVO.isVerified;
//			[self.contentView addSubview:verifiedImageView];
//		}
	}
}


#pragma mark - Navigation
- (void)_goDeselect {
	_isSelected = NO;
//	[self _toggleTintCycle:_isSelected];
	
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
	_isSelected = YES;
	[self _toggleTintCycle:_isSelected];
	
	_toggledOnButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_toggledOffButton.hidden = YES;
		
//		[self _toggleTintCycle:_isSelected];
		
		if (self.trivialUserVO != nil)
			[self.delegate userToggleViewCell:self didSelectTrivialUser:_trivialUserVO];
		
		else
			[self.delegate userToggleViewCell:self didSelectContactUser:_contactUserVO];
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		_avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[urlPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
}

- (void)_nextTintCycle {
	_isTintCycleFull = !_isTintCycleFull;
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:TINT_FADE_DURATION];
	[_overlayTintView setBackgroundColor:(_isTintCycleFull) ? TOP_TINT_COLOR : BOT_TINT_COLOR];
	[UIView commitAnimations];
}


- (void)_toggleTintCycle:(BOOL)isCycling {
	_isTintCycleFull = NO;
	
	if (_tintTimer != nil) {
		[_tintTimer invalidate];
		_tintTimer = nil;
	}
	
	[_overlayTintView.layer removeAllAnimations];
	_overlayTintView.backgroundColor = BOT_TINT_COLOR;
	_overlayTintView.hidden = !isCycling;
	
	if (isCycling) {
		_tintTimer = [NSTimer scheduledTimerWithTimeInterval:TINT_TIMER_DURATION
													  target:self
													selector:@selector(_nextTintCycle)
													userInfo:nil
													 repeats:YES];
	} else {
		
	}
}

@end
