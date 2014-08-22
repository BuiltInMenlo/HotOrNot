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
		
//		_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 0.0, 64.0, 64.0)];
//		[self.contentView addSubview:_avatarImageView];
		
//		[[HONImageBroker sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"contactMask"]];
		
//		_avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_avatarButton.frame = _avatarImageView.frame;
//		[self.contentView addSubview:_avatarButton];
			
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 22.0, 180.0, 18.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unverifiedUserArrow"]];
		_arrowImageView.frame = CGRectOffset(_arrowImageView.frame, 64.0 - 56, 28.0);
		_arrowImageView.hidden = YES;
		[self.contentView addSubview:_arrowImageView];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(83.0 - 56, 33.0, 25.0, 15.0)];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
		_scoreLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.hidden = YES;
		_scoreLabel.text = @"0";
		[self.contentView addSubview:_scoreLabel];
		
		
		_overlayTintView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight)];
		_overlayTintView.backgroundColor = BOT_TINT_COLOR;
		//[self.contentView addSubview:_overlayTintView];
		
		
		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:_toggledOffButton];
		
		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = _toggledOffButton.frame;
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		_toggledOnButton.alpha = (int)_isSelected;
		[self.contentView addSubview:_toggledOnButton];
		
		//[self _toggleTintCycle:_isSelected];
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

- (void)setTrivialUserVO:(HONTrivialUserVO *)trivialUserVO {
	_trivialUserVO = trivialUserVO;
	NSLog(@":|: CELL >> TRIVIALUSER:[%@]", trivialUserVO.username);
	
	[_toggledOnButton removeTarget:self action:@selector(_goDeselectContactUser) forControlEvents:UIControlEventAllEvents];
	[_toggledOffButton removeTarget:self action:@selector(_goSelectContactUser) forControlEvents:UIControlEventAllEvents];
	
	[_toggledOnButton addTarget:self action:@selector(_goDeselectTrivialUser) forControlEvents:UIControlEventTouchUpInside];
	[_toggledOffButton addTarget:self action:@selector(_goSelectTrivalUser) forControlEvents:UIControlEventTouchUpInside];
	
	NSLog(@"AVATAR:[%@]", _trivialUserVO.avatarPrefix);
//	if ([_trivialUserVO.avatarPrefix rangeOfString:@"default"].location == NSNotFound)
//		[self _loadAvatarImageFromPrefix:_trivialUserVO.avatarPrefix];
//	
//	else
//		_avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder"];
//	
//	[_avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	
	_arrowImageView.image = [UIImage imageNamed:(_trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"];
	_arrowImageView.hidden = NO;
	
	_scoreLabel.textColor = (_trivialUserVO.totalUpvotes > 0) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
	_scoreLabel.text = [@"" stringFromInt:_trivialUserVO.totalUpvotes];
	_scoreLabel.hidden = NO;
	
	_nameLabel.frame = CGRectOffset(_nameLabel.frame, 0.0, -9.0);
	_nameLabel.text = _trivialUserVO.username;
	
//	if (trivialUserVO.isVerified) {
//		UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
//		verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 45.0, 33.0);
//		verifiedImageView.hidden = !trivialUserVO.isVerified;
//		[self.contentView addSubview:verifiedImageView];
//	}
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	[_toggledOnButton removeTarget:self action:@selector(_goDeselectContactUser) forControlEvents:UIControlEventAllEvents];
	[_toggledOffButton removeTarget:self action:@selector(_goSelectContactUser) forControlEvents:UIControlEventAllEvents];
	
	[_toggledOnButton addTarget:self action:@selector(_goDeselectContactUser) forControlEvents:UIControlEventTouchUpInside];
	[_toggledOffButton addTarget:self action:@selector(_goSelectContactUser) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	NSString *nameCaption = _contactUserVO.fullName;//(_contactUserVO.contactType == HONContactTypeUnmatched) ? _contactUserVO.fullName : _contactUserVO.username;
	
//	_avatarImageView.image = _contactUserVO.avatarImage;
//	if ([_contactUserVO.avatarData isEqualToData:UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])])
//		_avatarImageView.image = [UIImage imageNamed:@"avatarPlaceholder"];
	
//	else
//		[self _loadAvatarImageFromPrefix:[[HONClubAssistant sharedInstance] defaultCoverImageURL]];
	
	
	_nameLabel.attributedText = [[NSAttributedString alloc] initWithString:nameCaption attributes:@{}];
	if ([_contactUserVO.lastName length] > 0)
		[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14] range:[nameCaption rangeOfString:(ABPersonGetSortOrdering() == kABPersonCompositeNameFormatFirstNameFirst) ? _contactUserVO.firstName : _contactUserVO.lastName]];
	
	else
		[_nameLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14] range:[nameCaption rangeOfString:_contactUserVO.firstName]];
	
	
//	if (_contactUserVO.contactType == HONContactTypeMatched) {
//		[self _loadAvatarImageFromPrefix:_contactUserVO.avatarPrefix];
//		[_avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
//		
		_nameLabel.frame = CGRectOffset(_nameLabel.frame, 0.0, -9.0);
		
		_arrowImageView.image = [UIImage imageNamed:(_trivialUserVO.isVerified) ? @"verifiedUserArrow" : @"unverifiedUserArrow"];
		_arrowImageView.hidden = NO;
		
		
		_scoreLabel.textColor = (_trivialUserVO.totalUpvotes > 0) ? [[HONColorAuthority sharedInstance] honGreenTextColor] : [[HONColorAuthority sharedInstance] honGreyTextColor];
		_scoreLabel.text = [@"" stringFromInt:_trivialUserVO.totalUpvotes];
		_scoreLabel.hidden = NO;
		
		if (_trivialUserVO.isVerified) {
			UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUserIcon"]];
			verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 45.0, 33.0);
			verifiedImageView.hidden = !_trivialUserVO.isVerified;
			[self.contentView addSubview:verifiedImageView];
		}
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"family_club"] != nil) {
		NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"family_club"];
		
		if ([[[[[dict objectForKey:@"name"] componentsSeparatedByString:@" "] firstObject] lowercaseString] isEqualToString:[_contactUserVO.lastName lowercaseString]]) {
			UILabel *familyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x + 25.0, _nameLabel.frame.origin.y + 20.0, 220.0, 15.0)];
			familyLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
			familyLabel.textColor = [UIColor blackColor];
			familyLabel.backgroundColor = [UIColor clearColor];
			familyLabel.text = [NSString stringWithFormat:@"Invite your family to join the %@ club!", _contactUserVO.lastName];
			[self.contentView addSubview:familyLabel];
		}
	}
	
//	}
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
