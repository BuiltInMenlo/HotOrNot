//
//  HONUserAssistant.h
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HONRegexMatchUsernameGroup) {
	HONRegexMatchWordGroup = 0,
	HONRegexMatchEpochGroup,
	HONRegexMatchSuffixGroup
};

#import "HONTrivialUserVO.h"

@interface HONUserAssistant : NSObject
+ (HONUserAssistant *)sharedInstance;

- (int)activeUserID;
- (NSString *)activeUsername;
- (UIImage *)activeUserAvatar;
- (NSString *)activeUserAvatarURL;
- (NSDate *)activeUserLoginDate;
- (BOOL)activeUserNotificationsEnabled;
- (NSDate *)activeUserSignupDate;

- (NSDictionary *)activeUserInfo;
- (void)writeActiveUserInfo:(NSDictionary *)userInfo;
- (void)writeActiveUserAvatarFromURL:(NSString *)url;

- (NSString *)rndAvatarURL;
- (NSString *)avatarURLForUserID:(int)userID;
- (void)retrieveActivityScoreByUserID:(int)userID completion:(void (^)(id result))completion;
- (void)retrieveActivityByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion;
- (NSString *)usernameWithDigitsStripped:(NSString *)username;
- (NSString *)usernameForUserID:(int)userID;

- (void)writeClubMemberToUserLookup:(NSDictionary *)userInfo;
@end
