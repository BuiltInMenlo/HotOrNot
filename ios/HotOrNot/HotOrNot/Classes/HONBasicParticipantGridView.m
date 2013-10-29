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
	NSMutableArray *_cells;
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
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSnapThumbSize.height * (([_gridItems count] / 4) + 1))];
	[self addSubview:_holderView];
	
	NSLog(@"%@.layoutGrid -> FRAME:[%@]", [[self class] description], NSStringFromCGRect(_holderView.frame));
	
	_cells = [NSMutableArray new];
	
	// start creating cells
	_participantCounter = 0;
	for (NSDictionary *dict in _gridItems)
		[self createItemForParticipant:[dict objectForKey:@"participant"] fromChallenge:[dict objectForKey:@"challenge"]];

//	// attach long tap
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
}

- (void)createItemForParticipant:(HONOpponentVO *)opponentVO fromChallenge:(HONChallengeVO *)challengeVO {
	HONOpponentVO *vo = ([opponentVO.imagePrefix isEqualToString:_heroOpponentVO.imagePrefix]) ? challengeVO.creatorVO : opponentVO;
//	NSLog(@"\t--GRID IMAGE(%d):[%@]", _participantCounter, [NSString stringWithFormat:@"%@Large_640x1136.jpg", [vo.imagePrefix stringByReplacingOccurrencesOfString:@"https://d1fqnfrnudpaz6.cloudfront.net/" withString:@""]]);
	
	CGPoint pos = CGPointMake(kSnapThumbSize.width * (_participantCounter % 4), kSnapThumbSize.height * (_participantCounter / 4));
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
	[_holderView addSubview:imageHolderView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.imagePrefix]] placeholderImage:nil];
	[imageHolderView addSubview:imageView];
	
	if (![vo.subjectName isEqualToString:challengeVO.creatorVO.subjectName])
		[imageHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyVolleyOverlay"]]];
	
	_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_profileButton.frame = imageView.frame;
	_profileButton.hidden = YES;
	[_profileButton setTag:vo.userID];
	[imageHolderView addSubview:_profileButton];
	
	_participantCounter++;
	[_cells addObject:imageHolderView];
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
		}
		
		if (dict != nil)
			[self.delegate participantGridView:self showPreview:(HONOpponentVO *)[dict objectForKey:@"participant"] forChallenge:(HONChallengeVO *)[dict objectForKey:@"challenge"]];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate participantGridViewPreviewShowControls:self];
}

@end
