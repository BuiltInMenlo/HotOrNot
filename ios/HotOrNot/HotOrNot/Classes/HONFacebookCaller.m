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
		[params setObject:[NSString stringWithFormat:@"%@_l.jpg", vo.imageURL] forKey:@"image[0][url]"];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/pchallenge:%@", action] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			NSLog(@"POSTED TO ACTVITY :[%@]",[result objectForKey:@"id"]);
			
			if (error) {
				[[[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
			}
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
													  [NSString stringWithFormat:@"%@_l.jpg", vo.imageURL], @"picture",
													  vo.subjectName, @"name",
													  vo.subjectName, @"caption",
													  vo.creatorName, @"description", nil];
		
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

+ (void)postToFriendTimeline:(NSString *)fbID article:(HONChallengeVO *)vo {
	if ([HONAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@?cID=%d", [HONAppDelegate facebookCanvasURL], vo.challengeID], @"link",
													  [NSString stringWithFormat:@"%@_l.jpg", vo.imageURL], @"picture",
													  vo.subjectName, @"name",
													  vo.subjectName, @"caption",
													  vo.creatorName, @"description", nil];
		
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
@end
