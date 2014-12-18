//
//  HONSubjectViewCell.m
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSubjectViewCell.h"


@interface HONSubjectViewCell ()
@property (nonatomic, strong) UIImageView *selectedBGImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *selectButton;
@end

@implementation HONSubjectViewCell
@synthesize delegate = _delegate;
@synthesize subjectVO = _subjectVO;
@synthesize isSelected = _isSelected;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subjectRowBG_normal"]];
		
		_selectedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subjectRowBG_selected"]];
		_selectedBGImageView.alpha = 0.0;
		[self.contentView addSubview:_selectedBGImageView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 14.0, 303.0, 26.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_captionLabel];
	}
	
	return (self);
}

- (id)initAsSelected:(BOOL)isSelected {
	if ((self = [self init])) {
		_isSelected = isSelected;
		
		_captionLabel.textColor = (_isSelected) ? [UIColor whiteColor] : [[HONColorAuthority sharedInstance] honGrey80TextColor];
		
		if (_isSelected) {
			[UIView animateWithDuration:0.125 animations:^(void) {
				_selectedBGImageView.alpha = (int)_isSelected;
			} completion:^(BOOL finished) {
			}];
		}
	}
		
	return (self);
}

- (void)dealloc {
	
}

- (void)destroy {
	[super destroy];
}


#pragma mark - PublicAPIs
- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	_captionLabel.textColor = (_isSelected) ? [UIColor whiteColor] : [[HONColorAuthority sharedInstance] honGrey80TextColor];
	[UIView animateWithDuration:0.125 animations:^(void) {
		_selectedBGImageView.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
	}];
}

- (void)setSubjectVO:(HONSubjectVO *)subjectVO {
	_subjectVO = subjectVO;
	
	_captionLabel.text = _subjectVO.subjectName;
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(subjectViewCell:didSelectSubject:)])
		[self.delegate subjectViewCell:self didSelectSubject:_subjectVO];
}


@end
