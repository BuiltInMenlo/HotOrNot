//
//  HONSearchViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.04.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONSearchViewController : UIViewController
- (id)initAsUserSearch:(NSString *)username;
- (id)initAsSubjectSearch:(NSString *)subject;

- (void)retrieveUsers:(NSString *)username;
- (void)retrieveSubjects:(NSString *)subject;
@end
