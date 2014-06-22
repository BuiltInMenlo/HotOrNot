//
//  HONChallengeAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:27.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONChallengeAssistant.h"

@implementation HONChallengeAssistant
static HONChallengeAssistant *sharedInstance = nil;

+ (HONChallengeAssistant *)sharedInstance {
	static HONChallengeAssistant *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (BOOL)isChallengeParticipant:(HONChallengeVO *)challengeVO {
	for (HONOpponentVO *vo in challengeVO.challengers) {
		if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
			return (YES);
	}
	
	return ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == challengeVO.creatorVO.userID);
}

- (HONEmotionVO *)emotionForOpponent:(HONOpponentVO *)opponentVO {
	HONEmotionVO *emotionVO;
	
	for (HONEmotionVO *vo in [HONAppDelegate orthodoxEmojis]) {
		if ([[vo.emotionName lowercaseString] isEqualToString:[opponentVO.subjectName lowercaseString]]) {
			emotionVO = [HONEmotionVO emotionWithDictionary:vo.dictionary];
			break;
		}
	}
	
	return (emotionVO);
}

- (HONOpponentVO *)mostRecentOpponentInChallenge:(HONChallengeVO *)challengeVO byUserID:(int)userID {
	HONOpponentVO *opponentVO;
	
	if (userID == challengeVO.creatorVO.userID)
		opponentVO = challengeVO.creatorVO;
	
	else {
		NSLog(@"newestChallenge -> opponents:[%d]", [challengeVO.challengers count]);
		for (HONOpponentVO *vo in challengeVO.challengers) {
			if (userID == vo.userID) {
				opponentVO = vo;
				break;
			}
		}
	}
	
	return (opponentVO);
}


- (int)hasVoted:(int)challengeID {
	NSArray *voteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"votes"];
	
	for (NSNumber *cID in voteArray) {
		if ([cID intValue] == challengeID || -[cID intValue] == challengeID) {
			return ([cID intValue]);
		}
	}
	
	return (0);
}

- (void)setVoteForChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO {
	NSMutableArray *upvoteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"upvotes"] mutableCopy];
	NSDictionary *dict = @{@"challenge_id"		: [@"" stringFromInt:challengeVO.challengeID],
						   @"participant_id"	: [@"" stringFromInt:opponentVO.userID]};
	
//	[upvoteArray addObject:[NSNumber numberWithInt:(isCreator) ? challengeID : -challengeID]];
//	[[NSUserDefaults standardUserDefaults] setObject:voteArray forKey:@"votes"];
	
	[upvoteArray addObject:dict];
	[[NSUserDefaults standardUserDefaults] setObject:upvoteArray forKey:@"upvotes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSDictionary *)emptyChallengeDictionaryWithID:(int)challengeID {
	return (@{@"id"			:[@"" stringFromInt:challengeID],
			  @"added"		: @"1970-01-01 00:00:00",
			  @"challengers": @[],
			  @"comments"	: @"0",
			  @"creator"	: @{@"age"		:@"1970-01-01 00:00:00",
								@"avatar"	:@"",
								@"id"		:@"0",
								@"img"		:@"",
								@"score"	:@"0",
								@"subject"	:@"",
								@"username"	:@"",
								@"joined"	:@"1970-01-01 00:00:00"},
			  @"has_viewed"	: @"N",
			  @"is_celeb"	: @"0",
			  @"is_explore"	: @"1",
			  @"is_verify"	: @"0",
			  @"started"	: @"1970-01-01 00:00:00",
			  @"status"		: @"0",
			  @"subject"	: @"__#INVITE__",
			  @"updated"	: @"1970-01-01 00:00:00"});
}


- (HONOpponentVO *)fpoOpponent {
	return ([HONOpponentVO opponentWithDictionary:@{@"user_id"	: @"592",
													@"username"	: @"markus18",
													@"avatar"	: @"https://d3j8du2hyvd35p.cloudfront.net/defaultAvatar",
													@"img"		: @"https://d1fqnfrnudpaz6.cloudfront.net/a616f063d7b1477f95bca5098e15ef36_1396173765",
													@"subjects"	: @[@"happy",
																	@"excited",
																	@"stoked"],
													@"score"	: [@"" stringFromInt:arc4random() % 100],
													@"added"	: @"2014-05-01 14:23:10"}]);
}

@end
