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
@property (nonatomic, strong) UIImageView *imageLoadingView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@end

@implementation HONStatusUpdateCreatorView
@synthesize delegate = _delegate;

- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 84.0)])) {
		_statusUpdateVO = statusUpdateVO;
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"statusUpdateCreatorBG"]]];
		
		_imageLoadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingDots_50"]];
		_imageLoadingView.frame = CGRectOffset(_imageLoadingView.frame, 11.0, 17.0);
		[self addSubview:_imageLoadingView];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 17.0, 50.0, 50.0)];
		[self addSubview:_imageView];
		[[HONViewDispensor sharedInstance] maskView:_imageView withMask:[UIImage imageNamed:@"topicMask"]];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_imageView.image = image;
			
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
			_imageLoadingView = nil;
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[_imageView setImageWithURL:[NSURL URLWithString:[[[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL] stringByAppendingString:kSnapLargeSuffix]]];
			
			[_imageLoadingView stopAnimating];
			[_imageLoadingView removeFromSuperview];
			_imageLoadingView = nil;
		};
		
		
		
		NSString *url = _statusUpdateVO.imagePrefix;
		NSLog(@"URL:[%@]", url);
		[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]
															cachePolicy:kOrthodoxURLCachePolicy
														timeoutInterval:[HONAPICaller timeoutInterval]]
						  placeholderImage:nil
								   success:imageSuccessBlock
								   failure:imageFailureBlock];
		
		
		
		
		_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 12.0, 200.0, 16.0)];
		_usernameLabel.backgroundColor = [UIColor clearColor];
		_usernameLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.58];
		_usernameLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:14];
		_usernameLabel.text = _statusUpdateVO.username;
		[self addSubview:_usernameLabel];
		
		
		NSLog(@"TOPIC:[%@]", _statusUpdateVO.topicName);
		NSLog(@"SUBJECT:[%@]", _statusUpdateVO.subjectName);;
		
		
		NSString *actionCaption = [NSString stringWithFormat:@"- is %@ %@", [_statusUpdateVO.topicName lowercaseString], _statusUpdateVO.subjectName];
		_subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 32.0, 220.0, 20.0)];
		_subjectLabel.backgroundColor = [UIColor clearColor];
		_subjectLabel.textColor = [UIColor blackColor];
		_subjectLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:16];
		_subjectLabel.text = actionCaption;
		[self addSubview:_subjectLabel];
		
		if ([actionCaption rangeOfString:_statusUpdateVO.subjectName].location != NSNotFound) {
			[_subjectLabel setFont:[[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:16] range:[actionCaption rangeOfString:_statusUpdateVO.subjectName]];
			
			if ([_statusUpdateVO.appStoreURL length] > 0) {
				UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
				linkButton.frame = [_subjectLabel boundingRectForSubstring:_statusUpdateVO.subjectName];
				[linkButton addTarget:self action:@selector(_goAppStoreURL) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:linkButton];
			}
		}
		
		
		UIImageView *timeIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeIcon"]];
		timeIconImageView.frame = CGRectOffset(timeIconImageView.frame, 72.0, 57.0);
		[self addSubview:timeIconImageView];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(88.0, 57.0, 208.0, 16.0)];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		timeLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
		timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_statusUpdateVO.addedDate];
		[self addSubview:timeLabel];
		
		_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_upVoteButton.frame = CGRectMake(272.0, 0.0, 44.0, 44.0);
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateDisabled];
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateNormal];
		[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
		[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
		//[self addSubview:_upVoteButton];
		
		_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_downVoteButton.frame = CGRectMake(272.0, 40.0, 44.0, 44.0);
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateDisabled];
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateNormal];
		[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
		[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
		//[self addSubview:_downVoteButton];
		
		NSLog(@"HAS VOTED:[%@]", NSStringFromBOOL([[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]));
		if (![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]) {
			[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
			[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
		}
		
		_scoreLabel = [[HONRefreshingLabel alloc] initWithFrame:CGRectMake(272.0, 33.0, 44.0, 20.0)];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
		_scoreLabel.textAlignment = NSTextAlignmentCenter;
		_scoreLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[self addSubview:_scoreLabel];
	}
	
	return (self);
}


#pragma mark - Public APIs
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
