//
//  HONUserAssistant.m
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserAssistant.h"

@implementation HONUserAssistant
static HONUserAssistant *sharedInstance = nil;

+ (HONUserAssistant *)sharedInstance {
	static HONUserAssistant *s_sharedInstance = nil;
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


- (void)retrieveActivityByUserID:(int)userID fromPage:(int)page completion:(void (^)(id result))completion {
	[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:page completion:^(NSDictionary *result) {
		
		NSLog(@"ON PAGE:[%d]", page);
		NSLog(@"RETRIEVED:[%d]", [[result objectForKey:@"results"] count]);
		
		if (completion)
			completion([result objectForKey:@"results"]);
	}];
}

- (NSString *)usernameWithDigitsStripped:(NSString *)username {
	NSString *strippedName;
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{,2})\\.(\\d{,2}))"
																		   options:NSRegularExpressionCaseInsensitive
																			 error:&error];
	
	NSArray *matches = [regex matchesInString:username options:0 range:NSMakeRange(0, [username length])];
	
	if ([matches count] > 0) {
		NSLog(@"[matches firstObject]: [%@]", [matches firstObject]);
		for (NSTextCheckingResult *match in matches) {
			NSLog(@"match: [%@]", match);
			
			return ([username substringWithRange:[match rangeAtIndex:HONRegexMatchWordGroup]]);
		}
		
	} else
		return (username);

//	NSRegularExpression *matchRegEx = [NSRegularExpression regularExpressionWithPattern:@"(\w\d+.\d+)"
//								  options:NSRegularExpressionCaseInsensitive
//								  error:nil];
//	
//	return([matchRegEx stringByReplacingMatchesInString:username options:0
//												  range:NSMakeRange(0, [username length])
//										   withTemplate:@""]);
	
	
}

- (void)retrieveActivityScoreByUserID:(int)userID completion:(void (^)(id result))completion {
	__block int page = 1;
	__block NSMutableArray *activityItems = [NSMutableArray array];
	
	[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:1 completion:^(NSDictionary *result) {
		NSLog(@"TOTAL:[%d]", [[result objectForKey:@"count"] intValue]);
		
		[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
		while ([activityItems count] < [[result objectForKey:@"count"] intValue]) {
			[[HONAPICaller sharedInstance] retrieveActivityForUserByUserID:userID fromPage:++page completion:^(NSDictionary *result) {;
				[activityItems addObjectsFromArray:[result objectForKey:@"results"]];
			}];
		}
		
		NSLog(@"FINISHED RETRIEVED:[%d]", [activityItems count]);
		
		__block int score = 0;
		[activityItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dict = (NSDictionary *)obj;
			
			NSLog(@"VOTE:[%d / %d]~(%@) -=- \"%@\"", [[dict objectForKey:@"status_update_id"] intValue], [[[dict objectForKey:@"subject_member"] objectForKey:@"id"] intValue], NSStringFromBOOL(([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])), [dict objectForKey:@"event_type"]);
			if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_UPVOTED"])
				score++;
			
			else if ([[[dict objectForKey:@"event_type"] uppercaseString] isEqualToString:@"STATUS_DOWNVOTED"])
				score--;
		}];
		
		if (completion)
			completion(@(score));
	}];
}


@end
