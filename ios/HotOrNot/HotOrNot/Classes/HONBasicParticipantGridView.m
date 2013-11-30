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
	UIView *_holderView;
	int _participantCounter;
}
@end

@implementation HONBasicParticipantGridView
@synthesize delegate = _delegate;

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height * (([challengeVO.challengers count] / 4) + 1))])) {
		_heroOpponentVO = opponentVO;
		
		_challenges = [NSMutableArray arrayWithObject:challengeVO];
	}
	
	return (self);
}

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height * (([challenges count] / 4) + 1))])) {
		_challenges = [challenges mutableCopy];
		_heroOpponentVO = opponentVO;
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)layoutGrid {
	_gridViews = [NSMutableArray array];
	
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSnapThumbSize.height * (([_gridItems count] / 4) + 1))];
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
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:_lpGestureRecognizer];
}

- (UIView *)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
	HONOpponentVO *vo = opponentVO;//([opponentVO.imagePrefix isEqualToString:_heroOpponentVO.imagePrefix]) ? challengeVO.creatorVO : opponentVO;
//	NSLog(@"\t--GRID IMAGE(%d):[%@]", _participantCounter, [NSString stringWithFormat:@"%@%@",  [vo.imagePrefix stringByReplacingOccurrencesOfString:@"https://d1fqnfrnudpaz6.cloudfront.net/" withString:@""]]);
	
	CGPoint pos = CGPointMake(kSnapThumbSize.width * (_participantCounter % 4), kSnapThumbSize.height * (_participantCounter / 4));
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[imageHolderView addSubview:imageView];
	//imageView.alpha = 0.0;
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
//			if (![vo.subjectName isEqualToString:challengeVO.creatorVO.subjectName])
//				[imageHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyVolleyOverlay"]]];
		}];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		NSLog(@"FAILED:[%@]", error.description);
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:vo.imagePrefix];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[vo.imagePrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval] * 50.0]
							placeholderImage:nil
									 success:imageSuccessBlock
									 failure:imageFailureBlock];
	
	_previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewButton.frame = imageView.frame;
	[_previewButton addTarget:self action:@selector(_goPreview:) forControlEvents:UIControlEventTouchUpInside];
	[_previewButton setTag:_participantCounter];
	[imageHolderView addSubview:_previewButton];
	
	return (imageHolderView);
}


#pragma mark - Navigation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_holderView];
//		NSLog(@"TOUCHPT:[%@]", NSStringFromCGPoint(touchPoint));
		
		NSDictionary *dict = [NSDictionary dictionary];
		if (CGRectContainsPoint(_holderView.frame, touchPoint)) {
			int row = ((int)(touchPoint.y - _holderView.frame.origin.y) / (kSnapThumbSize.height + 1.0));
			int col = ((int)touchPoint.x / (kSnapThumbSize.width + 1.0));
			int idx = (row * 4) + col;
			
			NSLog(@"COORDS FOR CELL:[%d] -> (%d, %d)", idx, col, row);
			dict = (idx < [_gridItems count]) ? [_gridItems objectAtIndex:idx] : nil;
			
			_selectedChallengeVO = [dict objectForKey:@"challenge"];
			_selectedOpponentVO = [dict objectForKey:@"participant"];
		}
		
		if (dict != nil)
			[self.delegate participantGridView:self showProfile:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - Navigation
- (void)_goPreview:(id)sender {
	
	NSDictionary *dict = [_gridItems objectAtIndex:[sender tag]];
//	_selectedChallengeVO = (HONChallengeVO *)[dict objectForKey:@"challenge"];
//	_selectedOpponentVO = (HONOpponentVO *)[dict objectForKey:@"participant"];
//	if (_selectedChallengeVO != nil && _selectedOpponentVO != nil)
		[self.delegate participantGridView:self showPreview:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
}

@end
