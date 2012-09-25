//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>


+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;

+(void)writeFBProfile:(NSDictionary *)userInfo;
+(NSDictionary *)fbProfileForUser;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

+ (NSArray *)fbPermissions;

+ (int)secondsBeforeDate:(NSDate *)date;
+ (int)minutesBeforeDate:(NSDate *)date;
+ (int)hoursBeforeDate:(NSDate *)date;


#define kServerPath @"http://discover.getassembly.com/hotornot/api"
#define kUsersAPI @"Users.php"
#define kChallengesAPI @"Challenges.php"
#define kPopularAPI @"Popular.php"

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
