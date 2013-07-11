//
//  HONTimelineItemViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"


@protocol HONTimelineItemViewCellDelegate;
@interface HONTimelineItemViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;
- (id)initAsStartedCell:(BOOL)hasStarted;

@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, assign) id <HONTimelineItemViewCellDelegate> delegate;
@end


@protocol HONTimelineItemViewCellDelegate
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showSubjectChallenges:(NSString *)subjectName;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showUserChallenges:(NSString *)username;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtCreator:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtChallenger:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapWithSubject:(NSString *)subjectName;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell acceptChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO;
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO;
@end