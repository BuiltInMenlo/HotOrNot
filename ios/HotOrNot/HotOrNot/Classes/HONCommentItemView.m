//
//  HONCommentItemView.m
//  HotOrNot
//
//  Created by BIM  on 12/31/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentItemView.h"

@interface HONCommentItemView()
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation HONCommentItemView
@synthesize commentVO = _commentVO;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:(frame.origin.y == 0.0) ? @"settingsRowBG-f_normal": @"settingsRowBG_normal"]]];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 14.0, 303.0, 26.0)];
		_captionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textColor = [[HONColorAuthority sharedInstance] honGrey80TextColor];
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_captionLabel];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 19.0, 30.0, 16.0)];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:14];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		[self addSubview:_timeLabel];
		
		
		UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		overlayButton.frame = CGRectFromSize(self.frame.size);
		//		[overlayButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateNormal];
				[overlayButton setBackgroundImage:[UIImage imageNamed:@"settingsRowBG_selected"] forState:UIControlStateHighlighted];
		//		[overlayButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:overlayButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
//	CGSize size = [_commentVO.textContent boundingRectWithSize:_captionLabel.frame.size
//										options:NSStringDrawingTruncatesLastVisibleLine
//									 attributes:@{NSFontAttributeName:_captionLabel.font}
//										context:nil].size;

//	_captionLabel.frame = CGRectExtendHeight(_captionLabel.frame, (size.width > _captionLabel.frame.size.width) ? 22.0 : 0.0);
//	_captionLabel.frame = CGRectOffset(_captionLabel.frame, 0.0, -4.0);
//	_captionLabel.numberOfLines = (size.width > _captionLabel.frame.size.width) ? 2 : 1;
	_captionLabel.text = _commentVO.textContent;
	
//	_timeLabel.frame = CGRectMake(8.0, _captionLabel.frame.origin.y + _captionLabel.frame.size.height + 4.0, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
	_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_commentVO.addedDate];
}

@end
