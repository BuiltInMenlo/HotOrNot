//
//  HONMailActivity.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/28/13 @ 10:03 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONMailActivity.h"

@implementation HONMailActivity

- (NSString *)activityType {
	return (UIActivityTypeMail);
}

- (NSString *)activityTitle {
	return (@"Mail");
}

- (UIImage *)activityImage {
	return ([UIImage imageNamed:@"checkmarkButton_nonActive"]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	return (YES);
}

- (UIViewController *)activityViewController {
	return ([self activityViewController]);
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	NSLog(@"performActivity");
}

- (void)performActivity {
	NSLog(@"performActivity");
}

- (void)activityDidFinish:(BOOL)completed {
	[super activityDidFinish:completed];
	
	NSLog(@"activityDidFinish");
}


@end
