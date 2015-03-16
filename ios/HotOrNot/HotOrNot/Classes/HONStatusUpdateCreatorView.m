//
//  HONStatusUpdateCreatorView.m
//  HotOrNot
//
//  Created by BIM  on 1/7/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"

#import "HONStatusUpdateCreatorView.h"
#import "HONRefreshingLabel.h"

@interface HONStatusUpdateCreatorView()
@property (nonatomic, strong) UILabel *participantsLabel;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@end

@implementation HONStatusUpdateCreatorView
@synthesize statusUpdateVO = _statusUpdateVO;
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 84.0)])) {
		_statusUpdateVO = statusUpdateVO;
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusUpdateCreatorBG"]]];
		
		_subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 31.0, 280.0, 20.0)];
		_subjectLabel.backgroundColor = [UIColor clearColor];
		_subjectLabel.textColor = [UIColor blackColor];
		_subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
		_subjectLabel.textAlignment = NSTextAlignmentCenter;
		_subjectLabel.text = [NSString stringWithFormat:@"“%@”", _statusUpdateVO.topicName];
		[self addSubview:_subjectLabel];
		
		_participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 46.0, 220.0, 18.0)];
		_participantsLabel.backgroundColor = [UIColor clearColor];
		_participantsLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		_participantsLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:14];
		_participantsLabel.textAlignment = NSTextAlignmentCenter;
		_participantsLabel.text = @"0 people here";
//		[self addSubview:_participantsLabel];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	_statusUpdateVO = statusUpdateVO;
	_subjectLabel.text = [NSString stringWithFormat:@"“%@”", _statusUpdateVO.topicName];
}

- (void)updateParticipantTotal:(int)participants {
	_participantsLabel.text = [NSString stringWithFormat:@"%d %@ here", participants, (participants == 1) ? @"person" : @"people"];
}

- (void)refreshScore {
	[_scoreLabel toggleLoading:YES];
	[[HONAPICaller sharedInstance] retrieveVoteTotalForStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSNumber *result) {
		_statusUpdateVO.score = [result intValue];
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:NO];
	}];
}


#pragma mark - Navigation
- (void)_goAppStoreURL {
	[_subjectLabel setTextColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.85] range:[_subjectLabel.text rangeOfString:_statusUpdateVO.subjectName]];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0625 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[_subjectLabel setTextColor:[UIColor blackColor] range:[_subjectLabel.text rangeOfString:_statusUpdateVO.subjectName]];
	});
	
	if ([self.delegate respondsToSelector:@selector(statusUpdateCreatorViewOpenAppStore:)])
		[self.delegate statusUpdateCreatorViewOpenAppStore:self];
}

- (void)_goDownVote {
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_scoreLabel toggleLoading:YES];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:_statusUpdateVO.statusUpdateID isUpVote:NO completion:^(NSDictionary *result) {
		_statusUpdateVO.score--;
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:NO];
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.statusUpdateID asUpVote:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}];
	
	if ([self.delegate respondsToSelector:@selector(statusUpdateCreatorViewDidDownVote:)])
		[self.delegate statusUpdateCreatorViewDidDownVote:self];
}

- (void)_goUpVote {
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_scoreLabel toggleLoading:YES];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:_statusUpdateVO.statusUpdateID isUpVote:YES completion:^(NSDictionary *result) {
		_statusUpdateVO.score++;
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:NO];
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.statusUpdateID asUpVote:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}];
	
	if ([self.delegate respondsToSelector:@selector(statusUpdateCreatorViewDidUpVote:)])
		[self.delegate statusUpdateCreatorViewDidUpVote:self];
}


@end
