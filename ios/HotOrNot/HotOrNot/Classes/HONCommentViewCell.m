//
//  HONCommentViewCell.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCommentViewCell.h"
#import "HONRefreshingLabel.h"

@interface HONCommentViewCell ()
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end


@implementation HONCommentViewCell
@synthesize delegate = _delegate;
@synthesize commentVO = _commentVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
		
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentRowBG"]];
		
		_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 8.0 - 4.0, 260.0, 20.0 + 22.0)];
		_commentLabel.backgroundColor = [UIColor clearColor];
		_commentLabel.textColor = [UIColor blackColor];
		_commentLabel.numberOfLines = 2;
		_commentLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:16];
		[self.contentView addSubview:_commentLabel];
		
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, _commentLabel.frame.origin.y + _commentLabel.frame.size.height + 4.0, 60.0, 16.0)];
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		_timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:14];
		[self.contentView addSubview:_timeLabel];
	}
	
	return (self);
}

- (void)dealloc {
	[self destroy];
}

- (void)destroy {
	[super destroy];
}


#pragma mark - Public APIs
- (void)setCommentVO:(HONCommentVO *)commentVO {
	_commentVO = commentVO;
	
//	CGSize size = [_commentVO.textContent boundingRectWithSize:_commentLabel.frame.size
//										options:NSStringDrawingTruncatesLastVisibleLine
//									 attributes:@{NSFontAttributeName:_commentLabel.font}
//										context:nil].size;

//	_commentLabel.frame = CGRectExtendHeight(_commentLabel.frame, (size.width > _commentLabel.frame.size.width) ? 22.0 : 0.0);
//	_commentLabel.frame = CGRectOffset(_commentLabel.frame, 0.0, -4.0);
//	_commentLabel.numberOfLines = (size.width > _commentLabel.frame.size.width) ? 2 : 1;
	_commentLabel.text = _commentVO.textContent;
	
//	_timeLabel.frame = CGRectMake(8.0, _commentLabel.frame.origin.y + _commentLabel.frame.size.height + 4.0, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
	_timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_commentVO.addedDate];
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(commentViewCell:didSelectComment:)])
		[self.delegate commentViewCell:self didSelectComment:_commentVO];
}


@end
