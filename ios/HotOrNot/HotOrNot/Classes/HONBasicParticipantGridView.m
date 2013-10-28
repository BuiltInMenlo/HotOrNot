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

//@property (nonatomic, strong) NSMutableArray *challenges;
//
//@property (nonatomic, strong) HONChallengeVO *challengeVO;
//@property (nonatomic, strong) HONOpponentVO *primaryOpponentVO;
//@property (nonatomic, strong) HONOpponentVO *selectedOpponentVO;
//
//@property (nonatomic, strong) NSMutableArray *gridOpponents;
//@property (nonatomic, strong) UIView *holderView;
//@property (nonatomic) int participantCounter;
//@end

@implementation HONBasicParticipantGridView
@synthesize delegate = _delegate;
@synthesize primaryOpponentVO = _primaryOpponentVO;
@synthesize challenges = _challenges;
@synthesize challengeVO = _challengeVO;
@synthesize selectedOpponentVO = _selectedOpponentVO;
@synthesize gridOpponents = _gridOpponents;

- (id)initAtPos:(int)yPos forChallenge:(HONChallengeVO *)challengeVO asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height * (([challengeVO.challengers count] / 4) + 1))])) {
		self.primaryOpponentVO = opponentVO;
		self.selectedOpponentVO = nil;
		
		self.challengeVO = challengeVO;
		self.challenges = [NSMutableArray arrayWithObject:self.challengeVO];
		
		
		NSLog(@"[%@] -> (DETAILS INIT) %d", [[self class] description], [self.challenges count]);
	}
	
	return (self);
}

- (id)initAtPos:(int)yPos forChallenges:(NSArray *)challenges asPrimaryOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, yPos, 320.0, kSnapThumbSize.height * (([challenges count] / 4) + 1))])) {
		self.primaryOpponentVO = opponentVO;
		self.selectedOpponentVO = nil;
		
		self.challenges = [challenges mutableCopy];
		self.challengeVO = nil;
		
		NSLog(@"[%@] -> (PROFILE)", [[self class] description]);
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)layoutGrid {
	_holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kSnapThumbSize.height * (([self.gridOpponents count] / 4) + 1))];
	[self addSubview:_holderView];
	
//	NSLog(@"layoutGrid (SUPER) -> [%@]", NSStringFromCGRect(_holderView.frame));
	
	_cells = [NSMutableArray new];
	
	// start creating cells
	_participantCounter = 0;
	for (HONOpponentVO *challenger in self.gridOpponents)
		[self createItemForParticipant:challenger];

//	// attach long tap
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
}

- (void)createItemForParticipant:(HONOpponentVO *)opponentVO {
	HONOpponentVO *vo = ([opponentVO.imagePrefix isEqualToString:_primaryOpponentVO.imagePrefix]) ? _challengeVO.creatorVO : opponentVO;
	NSLog(@"\t--GRID IMAGE(%d):[%@]", _participantCounter, [NSString stringWithFormat:@"%@Large_640x1136.jpg", [vo.imagePrefix stringByReplacingOccurrencesOfString:@"https://d1fqnfrnudpaz6.cloudfront.net/" withString:@""]]);
	
	CGPoint pos = CGPointMake(kSnapThumbSize.width * (_participantCounter % 4), kSnapThumbSize.height * (_participantCounter / 4));
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapThumbSize.width, kSnapThumbSize.height)];
	imageHolderView.backgroundColor = [HONAppDelegate honDebugColorByName:@"red" atOpacity:0.33];
	[_holderView addSubview:imageHolderView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.imagePrefix]] placeholderImage:nil];
	[imageHolderView addSubview:imageView];
	
	if (![vo.subjectName isEqualToString:_challengeVO.creatorVO.subjectName])
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
		NSLog(@"TOUCH:[%@] -> %@", NSStringFromCGPoint(touchPoint), NSStringFromCGRect(_holderView.frame));
		
//		UIView *cell;
//		for (UIView *view in _cells) {
//			NSLog(@"CELL:[%@]", NSStringFromCGRect(view.frame));
//			if (CGRectContainsPoint(view.frame, touchPoint)) {
//				cell = view;
//				break;
//			}
//		}
//		NSLog(@"TOUCHED CELL:[%d]", cell.tag);
		
		if (CGRectContainsPoint(_holderView.frame, touchPoint)) {
			int row = ((int)(touchPoint.y - _holderView.frame.origin.y) / (kSnapThumbSize.height + 1.0));
			int col = ((int)touchPoint.x / (kSnapThumbSize.width + 1.0));
			int idx = row * 4 + col;
			
//			CGPoint coords = CGPointMake(((int)touchPoint.x / (kSnapThumbSize.width + 1.0)), ((int)(touchPoint.y - _holderView.frame.origin.y) / (kSnapThumbSize.height + 1.0)));
//			NSLog(@"coords:[%@] _[%d]_", NSStringFromCGPoint(coords), ((int)coords.y * 4) + (int)coords.x);
			NSLog(@"coords:(%d, %d) _[%d]_", col, row, idx);
			
			self.selectedOpponentVO = (idx < [self.gridOpponents count]) ? [self.gridOpponents objectAtIndex:idx] : nil;
		}
		
		if (self.selectedOpponentVO != nil)
			[self.delegate participantGridView:self showPreview:self.selectedOpponentVO forChallenge:self.challengeVO];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate participantGridViewPreviewShowControls:self];
}

@end
