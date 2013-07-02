//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONChallengeViewCell.h"


@interface HONChallengeViewCell()
@property (nonatomic, strong) UIButton *loadMoreButton;
@property (nonatomic, strong) UIImageView *hasSeenImageView;
@end

@implementation HONChallengeViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsLoadMoreCell:(BOOL)isMoreLoadable {
	if ((self = [super init])) {
		if (isMoreLoadable) {
			_loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadMoreButton.frame = CGRectMake(0.0, 0.0, 320.0, 63.0);
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive"] forState:UIControlStateNormal];
			[_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active"] forState:UIControlStateHighlighted];
			[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_loadMoreButton];
		}
		
		[self hideChevron];
	}
	
	return (self);
}


- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[self hideChevron];
	BOOL isCreator = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID;
	
	UIView *challengeImgHolderView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 12.0, kSnapThumbDim, kSnapThumbDim)];
	challengeImgHolderView.clipsToBounds = YES;
	[self addSubview:challengeImgHolderView];
	
	UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbDim, kSnapThumbDim)];
	challengeImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[challengeImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_t.jpg", (isCreator && (![_challengeVO.status isEqualToString:@"Created"] && ![_challengeVO.status isEqualToString:@"Waiting"])) ? _challengeVO.challengerImgPrefix : _challengeVO.creatorImgPrefix]] placeholderImage:nil];
	[challengeImgHolderView addSubview:challengeImageView];
	
	UILabel *challengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 15.0, 180.0, 20.0)];
	challengerLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	challengerLabel.textColor = [HONAppDelegate honBlueTextColor];
	challengerLabel.backgroundColor = [UIColor clearColor];
	challengerLabel.text = ([_challengeVO.status isEqualToString:@"Created"]) ? @"You snapped…" : [NSString stringWithFormat:@"@%@", (isCreator) ? _challengeVO.challengerName : _challengeVO.creatorName];
	[self addSubview:challengerLabel];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[dateFormatter setDateFormat:@"h:mma"];
		
	UILabel *subjectTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 31.0, 200.0, 18.0)];
	subjectTimeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	subjectTimeLabel.textColor = [HONAppDelegate honGrey455Color];
	subjectTimeLabel.backgroundColor = [UIColor clearColor];
	subjectTimeLabel.text = [NSString stringWithFormat:@"%@ at %@", _challengeVO.subjectName, [[dateFormatter stringFromDate:_challengeVO.updatedDate] lowercaseString]];
	[self addSubview:subjectTimeLabel];
	
	_hasSeenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(265.0, 9.0, 44.0, 44.0)];
	_hasSeenImageView.image = [UIImage imageNamed:(_challengeVO.hasViewed) ? @"viewedSnapCheck" : @"newSnapDot"];
	[self addSubview:_hasSeenImageView];
	
	
	
	UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(69.0, 34.0, 18.0, 18.0)];
	arrowImageView.image = [UIImage imageNamed:(isCreator) ? @"outboundArrow" : @"inboundArrow"];
	//[self addSubview:arrowImageView];
	
	if ([_challengeVO.status isEqualToString:@"Created"]) {
	} else if ([_challengeVO.status isEqualToString:@"Waiting"]) {
	} else if ([_challengeVO.status isEqualToString:@"Accept"]) {
	} else if ([_challengeVO.status isEqualToString:@"Flagged"]) {
	} else if ([_challengeVO.status isEqualToString:@"Started"] || [_challengeVO.status isEqualToString:@"Completed"]) {
	}
}

- (void)toggleLoadMore:(BOOL)isEnabled {
	if (isEnabled) {
		[_loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_loadMoreButton];
	
	} else {
		[_loadMoreButton removeTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		[_loadMoreButton removeFromSuperview];
	}
}

- (void)updateHasSeen {
	_hasSeenImageView.image = [UIImage imageNamed:@"viewedSnapCheck"];
}


#pragma mark - Navigation
- (void)_goLoadMore {
	[self.delegate challengeViewCellLoadMore:self];
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

@end
