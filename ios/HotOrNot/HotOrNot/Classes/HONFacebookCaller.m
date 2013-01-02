//
//  HONFacebookCaller.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.22.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONFacebookCaller.h"

#import "HONAppDelegate.h"

@implementation HONFacebookCaller

@synthesize facebook  =_facebook;

+ (NSArray *)friendIDsFromUser:(NSString *)fbID {
	NSMutableArray *friends = [NSMutableArray array];
	
	[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
			[friends addObject:friend];
		}
	}];
	
	return ([friends copy]);
}

+ (void)postStatus:(NSString *)msg {
	if ([HONAppDelegate allowsFBPosting]) {
		NSDictionary *params = [NSDictionary dictionaryWithObject:msg forKey:@"message"];
		[FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			NSLog(@"POSTED STATUS");
		}];
	}
}

+ (void)postToActivity:(HONChallengeVO *)vo withAction:(NSString *)action {
	if ([HONAppDelegate allowsFBPosting]) {
		NSMutableDictionary *params = [NSMutableDictionary new];
		[params setObject:[NSString stringWithFormat:@"%@?cID=%d", [HONAppDelegate facebookCanvasURL], vo.challengeID] forKey:@"challenge"];
		[params setObject:[NSString stringWithFormat:@"%@_l.jpg", vo.creatorImgPrefix] forKey:@"image[0][url]"];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/pchallenge:%@", action] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			NSLog(@"POSTED TO ACTVITY :[%@]",[result objectForKey:@"id"]);
			
//			if (error)
//				[[[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		}];
	}
}

+ (void)postToTicker:(NSString *)msg {
	if ([HONAppDelegate allowsFBPosting]) {
	}
}

+ (void)postToTimeline:(HONChallengeVO *)vo {
	if ([HONAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@?cID=%d", [HONAppDelegate facebookCanvasURL], vo.challengeID], @"link",
													  [NSString stringWithFormat:@"%@_l.jpg", vo.creatorImgPrefix], @"picture",
													  @"PicChallengeMe", @"name",
													  vo.subjectName, @"caption",
													  [NSString stringWithFormat:@"%@ just challenged %@ to take the %@ challenge, tap here to challenge back!", vo.creatorName, vo.challengerName, vo.subjectName], @"description", nil];
		
		[FBRequestConnection startWithGraphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)postToFriendTimeline:(NSString *)fbID challenge:(HONChallengeVO *)vo {
	if ([HONAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@?cID=%d", [HONAppDelegate facebookCanvasURL], vo.challengeID], @"link",
													  [NSString stringWithFormat:@"%@_l.jpg", vo.creatorImgPrefix], @"picture",
													  @"PicChallengeMe", @"name",
													  vo.subjectName, @"caption",
													  [NSString stringWithFormat:@"%@ just challenged you to a %@ photo, tap here to challenge back!", vo.creatorName, vo.subjectName], @"description", nil];
		
		NSLog(@"fbID:[%@]", fbID);
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg {
	if ([HONAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  msg, @"message",
													  [NSString stringWithFormat:@"%@", [HONAppDelegate facebookCanvasURL]], @"link",
													  @"name here", @"name",
													  @"caption", @"caption",
													  @"info", @"description", nil];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)sendAppRequestToUser:(NSString *)fbID {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to a PicChallenge!",  @"message",
											 fbID, @"to", 
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:FacebookAppID andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
					andParams:params
				 andDelegate:nil];
}

+ (void)sendAppRequestToUser:(NSString *)fbID challenge:(HONChallengeVO *)vo {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 [NSString stringWithFormat:@"It's your turn at a %@ PicChallenge!", vo.subjectName],  @"message",
											 fbID, @"to",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:FacebookAppID andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

+ (void)sendAppRequestBroadcast {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to a PicChallenge!",  @"message",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:FacebookAppID andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

+ (void)sendAppRequestBroadcastWithIDs:(NSArray *)ids {
	NSString *list = @"";
	
	for (NSString *fbID in ids) {
		list = [list stringByAppendingFormat:@"%@,", fbID];
	}
	
	list = [list substringToIndex:[list length] - 1];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to a PicChallenge!",  @"message",
											 list, @"to",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:FacebookAppID andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

@end
