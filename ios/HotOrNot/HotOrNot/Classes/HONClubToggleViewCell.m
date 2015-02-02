//
//  HONClubToggleViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubToggleViewCell.h"

@interface HONClubToggleViewCell ()
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *toggledOnButton;
@property (nonatomic, strong) UIButton *toggledOffButton;
@property (nonatomic) HONClubToggleViewCellType viewCellType;
@end

@implementation HONClubToggleViewCell
@synthesize delegate = _delegate;
@synthesize userClubVO = _userClubVO;
@synthesize isSelected = _isSelected;

- (id)init {
	if ((self = [self initAsCellType:HONClubToggleViewCellTypeClub])) {
	}
	
	return (self);
}

- (id)initAsCellType:(HONClubToggleViewCellType)viewCellType {
	if ((self = [super init])) {
		_viewCellType = viewCellType;
		_isSelected = NO;
		
		if (viewCellType == HONClubToggleViewCellTypeClub)
			self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsCellBG_normal"]];

		_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 11.0, 44.0, 44.0)];
		_coverImageView.alpha = 0.0;
		[self.contentView addSubview:_coverImageView];
		
//		[[HONImageBroker sharedInstance] maskView:_coverImageView withMask:[UIImage imageNamed:@"thumbPhotoMask"]];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 23.0, 180.0, 18.0)];
		_nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_nameLabel];
		
		_toggledOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = CGRectMake(269.0, 11.0, 44.0, 44.0);
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOffButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_toggledOffButton];
		
		_toggledOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = _toggledOffButton.frame;
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		[_toggledOnButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_toggledOnButton.alpha = (int)_isSelected;
		[self.contentView addSubview:_toggledOnButton];
		
		if (_viewCellType == HONClubToggleViewCellTypeCreateClub) {
			[_toggledOffButton removeFromSuperview];
			[_toggledOnButton removeFromSuperview];
		}
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserClubVO:(HONUserClubVO *)userClubVO {
	_userClubVO = userClubVO;
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_coverImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
		
		_coverImageView.image = [UIImage imageNamed:@"defaultClubCover"];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_coverImageView.alpha = 1.0;
		} completion:nil];
	};
	
//	NSLog(@"CLUB COVER:[%@]", [_userClubVO.coverImagePrefix stringByAppendingString:kSnapThumbSuffix]);
	[_coverImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userClubVO.coverImagePrefix stringByAppendingString:kSnapThumbSuffix]]
															 cachePolicy:kOrthodoxURLCachePolicy
														 timeoutInterval:[HONAPICaller timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	_nameLabel.text = _userClubVO.clubName;
}


- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	NSLog(@"toggleSelected:[%@]", NSStringFromBOOL(_isSelected));
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
	}];
}

- (void)toggleIndicator:(BOOL)isEnabled {
	_toggledOffButton.hidden = !isEnabled;
	_toggledOnButton.hidden = !isEnabled;
}

- (void)toggleOnWithReset:(BOOL)isReset {
	_isSelected = YES;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
		_toggledOnButton.alpha = (int)!isReset;
	}];
}

- (void)setIsSelected:(BOOL)isSelected {
	[self toggleSelected:isSelected];
}

- (BOOL)isSelected {
	return (_isSelected);
}


#pragma mark - Navigation
- (void)_goDeselect {
	_isSelected = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		if (_viewCellType == HONClubToggleViewCellTypeSelectAll) {
			if ([self.delegate respondsToSelector:@selector(clubToggleViewCell:selectAllToggled:)])
				[self.delegate clubToggleViewCell:self selectAllToggled:NO];
			
		} else {
			if ([self.delegate respondsToSelector:@selector(clubToggleViewCell:deselectedClub:)])
				[self.delegate clubToggleViewCell:self deselectedClub:_userClubVO];
			
		}
	}];
}

- (void)_goSelect {
	_isSelected = YES;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		if (_viewCellType == HONClubToggleViewCellTypeSelectAll) {
			if ([self.delegate respondsToSelector:@selector(clubToggleViewCell:selectAllToggled:)])
				[self.delegate clubToggleViewCell:self selectAllToggled:YES];
			
		} else {
			if ([self.delegate respondsToSelector:@selector(clubToggleViewCell:selectedClub:)])
				[self.delegate clubToggleViewCell:self selectedClub:_userClubVO];
		}
	}];
}


@end
