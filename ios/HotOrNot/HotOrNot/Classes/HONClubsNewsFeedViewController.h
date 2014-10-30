//
//  HONClubsNewsFeedViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

typedef NS_OPTIONS(NSUInteger, HONFeedContentType) {
	HONFeedContentTypeEmpty				= 0 << 0,	// 000000 - 0  */*
	HONFeedContentTypeAutoGenClubs		= 1 << 0,	// 000001 - 1  */*
	HONFeedContentTypeOwnedClubs		= 1 << 1,	// 000010 - 2  */*
	HONFeedContentTypeJoinedClubs		= 1 << 2,	// 000100 - 4  */*
	HONFeedContentTypeClubInvites		= 1 << 3,	// 001000 - 8  */*
	HONFeedContentTypeSuggestedClubs	= 1 << 4,	// 010000 - 16 */*
	HONFeedContentTypeMatchedClubs		= 1 << 5	// 100000 - 32 */*
};

typedef NS_ENUM(NSUInteger, HONClubsNewsFeedAlertType) {
	HONClubsNewsFeedAlertTypeJoinClub = 0,
	HONClubsNewsFeedAlertTypeInviteFriends,
	HONClubsNewsFeedAlertTypeCreateClub
};

@interface HONClubsNewsFeedViewController : HONViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@end
