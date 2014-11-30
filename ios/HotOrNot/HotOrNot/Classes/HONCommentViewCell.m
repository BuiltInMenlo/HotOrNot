//
//  HONCommentViewCell.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONCommentViewCell.h"

@interface HONCommentViewCell ()
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
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
		
		_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_upVoteButton.frame = CGRectMake(274.0, -6.0, 44.0, 44.0);
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Disabled"] forState:UIControlStateDisabled];
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Disabled"] forState:UIControlStateNormal];
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:_upVoteButton];
		
		_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_downVoteButton.frame = CGRectMake(274.0, 35.0, 44.0, 44.0);
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Disabled"] forState:UIControlStateDisabled];
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Disabled"] forState:UIControlStateNormal];
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:_downVoteButton];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(252.0, 28.0, 88.0, 16.0)];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
		_scoreLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
		_scoreLabel.textAlignment = NSTextAlignmentCenter;
		_scoreLabel.text = @"…";
		[self.contentView addSubview:_scoreLabel];
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
- (void)refreshScore {
	[[HONAPICaller sharedInstance] retrieveVoteTotalForChallengeWithChallengeID:_commentVO.commentID completion:^(NSNumber *result) {
		_commentVO.score = [result intValue];
		_scoreLabel.text = [@"" stringFromInt:_commentVO.score];
	}];
}

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
	
	[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForComment:_commentVO])];
	[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForComment:_commentVO])];
	
	if (![[HONClubAssistant sharedInstance] hasVotedForComment:_commentVO]) {
		[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
		[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	}
	
	[self refreshScore];
}


#pragma mark - Navigation
- (void)_goDownVote {
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	if ([self.delegate respondsToSelector:@selector(commentViewCell:didDownVoteComment:)])
		[self.delegate commentViewCell:self didDownVoteComment:_commentVO];
}

- (void)_goUpVote {
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	if ([self.delegate respondsToSelector:@selector(commentViewCell:didUpVoteComment:)])
		[self.delegate commentViewCell:self didUpVoteComment:_commentVO];
}

@end
