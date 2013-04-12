//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONChallengeViewCell.h"
#import "HONAppDelegate.h"

@interface HONChallengeViewCell()
@property (nonatomic, strong) UIButton *loadMoreButton;
@end

@implementation HONChallengeViewCell
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsBottomCell:(BOOL)isBottom {
	if ((self = [super init])) {
		if (isBottom) {
			_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadMoreButton.frame = CGRectMake(107.0, 16.0, 106.0, 34.0);
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive"] forState:UIControlStateNormal];
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active"] forState:UIControlStateHighlighted];
			[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_loadMoreButton];
			
			[self hideChevron];
		}
	}
	
	return (self);
}


- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UIView *creatorImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(29.0, 13.0, 38.0, 38.0)];
	creatorImgHolderView.layer.cornerRadius = (int)[HONAppDelegate isRetina5] * 2.0;
	creatorImgHolderView.clipsToBounds = YES;
	[self addSubview:creatorImgHolderView];
	
	UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -8.0, kThumb1W, kThumb1H)];
	creatorImageView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
	[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", _challengeVO.creatorImgPrefix]] placeholderImage:nil];
	[creatorImgHolderView addSubview:creatorImageView];
		
	UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(76.0, 16.0, 180.0, 16.0)];
	challengeLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:11];
	challengeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	challengeLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:challengeLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(76.0, 36.0, 200.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:13];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(228.0, 6.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.addedDate];
	[self addSubview:timeLabel];
	
	if ([_challengeVO.status isEqualToString:@"Created"]) {
		challengeLabel.text = @"@You are waiting…";
		
	} else if ([_challengeVO.status isEqualToString:@"Waiting"]) {
		challengeLabel.text = [NSString stringWithFormat:@"@You snapped %@", _challengeVO.challengerName];
		
	} else if ([_challengeVO.status isEqualToString:@"Accept"]) {
		challengeLabel.text = [NSString stringWithFormat:@"@%@ snapped you", _challengeVO.creatorName];
		
		UIImageView *hasSeenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 20.0, 24.0, 24.0)];
		hasSeenImageView.image = [UIImage imageNamed:@"newSnapIcon"];
		hasSeenImageView.hidden = _challengeVO.hasViewed;
		[self addSubview:hasSeenImageView];
		
	} else if ([_challengeVO.status isEqualToString:@"Started"] || [_challengeVO.status isEqualToString:@"Completed"]) {
		challengeLabel.frame = CGRectOffset(challengeLabel.frame, 40.0, 0.0);
		challengeLabel.text = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID) ? [NSString stringWithFormat:@"@You snapped %@", _challengeVO.challengerName] : [NSString stringWithFormat:@"@%@ snapped you", _challengeVO.creatorName];
		subjectLabel.frame = CGRectOffset(subjectLabel.frame, 40.0, 0.0);
		
		UIView *challengerImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(69.0, 13.0, 38.0, 38.0)];
		challengerImgHolderView.clipsToBounds = YES;
		challengerImgHolderView.layer.cornerRadius = (int)[HONAppDelegate isRetina5] * 2.0;
		[self addSubview:challengerImgHolderView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -8.0, kThumb1W, kThumb1H)];
		challengerImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", _challengeVO.challengerImgPrefix]] placeholderImage:nil];
		[challengerImgHolderView addSubview:challengerImageView];
	}
}


//- (void)willTransitionToState:(UITableViewCellStateMask)state {
//	[super willTransitionToState:state];
//
//	NSLog(@"willTransitionToState");
//	
//	if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
//		for (UIView *subview in self.subviews) {
//			if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
//				UIImageView *deleteBtn = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//				[deleteBtn setImage:[UIImage imageNamed:@"genericGrayButton_nonActive"]];
//				[[subview.subviews objectAtIndex:0] addSubview:deleteBtn];
//			}
//		}
//	}
//}

- (void)disableLoadMore {
	[_loadMoreButton removeTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
	[_loadMoreButton removeFromSuperview];
}

#pragma mark - Navigation
- (void)_goLoadMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEXT_CHALLENGE_BLOCK" object:nil];
}

@end
