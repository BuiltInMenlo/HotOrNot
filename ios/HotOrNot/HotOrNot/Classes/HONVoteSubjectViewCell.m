//
//  HONVoteSubjectViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVoteSubjectViewCell.h"
#import "HONAppDelegate.h"
#import "HONChallengeVO.h"

@interface HONVoteSubjectViewCell() <UIScrollViewDelegate>
@end

@implementation HONVoteSubjectViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subject = subject;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 128.0)];
		bgImgView.image = [UIImage imageNamed:@"rowWhite_nonActive"];
		[self addSubview:bgImgView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 5.0, 260.0, 16.0)];
		subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		subjectLabel.textColor = [HONAppDelegate honGreyTxtColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.text = _subject;
		[self addSubview:subjectLabel];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)setChallenges:(NSMutableArray *)challenges {
	_challenges = challenges;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 22.0, 300.0, kImgSize)];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.contentSize = CGSizeMake([_challenges count] * kImgSize, kImgSize);
	//scrollView.opaque = NO;
	scrollView.scrollsToTop = NO;
	scrollView.pagingEnabled = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.alwaysBounceVertical = NO;
	scrollView.delegate = self;
	[self addSubview:scrollView];
	
	int offset = 0;
	for (HONChallengeVO *vo in _challenges) {
		UIImageView *creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset * kImgSize, 0.0, kImgSize, kImgSize)];
		creatorImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[creatorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", vo.creatorImgPrefix]] placeholderImage:nil];
		[scrollView addSubview:creatorImageView];
		
		UIImageView *challengerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((offset * kImgSize) + (kImgSize * 0.5), kImgSize * 0.5, kImgSize * 0.5, kImgSize * 0.5)];
		[challengerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", vo.challengerImgPrefix]] placeholderImage:nil];
		[scrollView addSubview:challengerImageView];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = CGRectMake(offset * kImgSize, 0.0, kImgSize, kImgSize);
		[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		//[self addSubview:selectButton];
		
		offset++;
	}
}


#pragma mark - Navigation
- (void)_goSelect {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_SUBJECT_SELECTED" object:[NSNumber numberWithInt:_index]];
}

@end
