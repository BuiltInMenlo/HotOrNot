//
//  HONImagePickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@interface HONImagePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithSubject:(NSString *)subject;
- (id)initWithSubject:(NSString *)subject withFriendID:(NSString *)fbID;
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithSubject:(NSString *)subject withUser:(int)userID;
@end
