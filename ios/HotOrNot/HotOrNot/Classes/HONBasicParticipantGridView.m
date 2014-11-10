//
//  HONParticipantGridView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 8:40 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONBasicParticipantGridView.h"

@interface HONBasicParticipantGridView () {
	int _participantCounter;
}
@end

@implementation HONBasicParticipantGridView
@synthesize delegate = _delegate;

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height)])) {
		_heroOpponentVO = opponentVO;
		
		_challenges = [NSMutableArray arrayWithObject:challengeVO];
	}
	
	return (self);
}

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height)])) {
		_challenges = [challenges mutableCopy];
		_heroOpponentVO = opponentVO;
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)layoutGrid {
	_gridViews = [NSMutableArray array];
	
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 320.0, kSnapThumbSize.height * (([_gridItems count] / 4) + ([_gridItems count] % 4 != 0)));
	_holderView = [[UIView alloc] initWithFrame:CGRectOffset(self.frame, 0.0, -self.frame.origin.y)];
	[self addSubview:_holderView];
	
	_participantCounter = 0;
	for (NSDictionary *dict in _gridItems) {
		UIView *gridItemView = [self createItemForParticipant:[dict objectForKey:@"participant"] fromChallenge:[dict objectForKey:@"challenge"]];
		[gridItemView setTag:_participantCounter];
		[_gridViews addObject:gridItemView];
		[_holderView addSubview:gridItemView];
		
		_participantCounter++;
	}

	// attach long tap
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:_lpGestureRecognizer];
}

- (UIView *)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
//	NSLog(@"\t--GRID IMAGE(%d):[%@]", _participantCounter, [NSString stringWithFormat:@"%@",  [opponentVO.imagePrefix stringByReplacingOccurrencesOfString:@"https://d1fqnfrnudpaz6.cloudfront.net/" withString:@""]]);
	
	CGPoint pos = CGPointMake(kSnapThumbSize.width * (_participantCounter % 4), kSnapThumbSize.height * (_participantCounter / 4));
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(kSnapThumbSize)];
	[imageHolderView addSubview:imageView];
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.frame = CGRectMake(55.0, 55.0, 24.0, 24.0);
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteIcon_nonActive"] forState:UIControlStateNormal];
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"deleteIcon_Active"] forState:UIControlStateHighlighted];
	[deleteButton addTarget:self action:@selector(_goDelete:) forControlEvents:UIControlEventTouchUpInside];
	[deleteButton setTag:_participantCounter];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			if (_participantGridViewType == HONParticipantGridViewTypeUsersProfile)
				[imageHolderView addSubview:deleteButton];
		}];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		NSLog(@"FAILED:[%@]", error.description);
//		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:opponentVO.imagePrefix completion:nil];
		imageHolderView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		if (_participantGridViewType == HONParticipantGridViewTypeUsersProfile)
			[imageHolderView addSubview:deleteButton];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[opponentVO.imagePrefix stringByAppendingString:kSnapThumbSuffix]]
													   cachePolicy:kOrthodoxURLCachePolicy
												   timeoutInterval:[HONAppDelegate timeoutInterval] * 50.0]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
	
	_previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewButton.frame = imageView.frame;
	[_previewButton addTarget:self action:(_participantGridViewType == HONParticipantGridViewTypeDetails) ? @selector(_goPreview:) : @selector(_goDetails:) forControlEvents:UIControlEventTouchUpInside];
	//[_previewButton addTarget:self action:@selector(_goPreview:) forControlEvents:UIControlEventTouchUpInside];
	[_previewButton setTag:_participantCounter];
	[imageHolderView addSubview:_previewButton];
	
	return (imageHolderView);
}


#pragma mark - Navigation
-(void)goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	NSLog(@"goLongPress:[%d]", lpGestureRecognizer.state);
	
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - Navigation
- (void)_goPreview:(id)sender {
	NSLog(@"_goPreview:[%@]", sender);
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	[self.delegate participantGridView:self showPreview:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
}

- (void)_goDetails:(id)sender {
	NSLog(@"_goDetails:[%@]", sender);
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	[self.delegate participantGridView:self showDetailsForChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
}

- (void)_goDelete:(id)sender {
	NSLog(@"_goDelete:[%@]", sender);
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
	
	[self.delegate participantGridView:self removeParticipantItem:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
}

@end
