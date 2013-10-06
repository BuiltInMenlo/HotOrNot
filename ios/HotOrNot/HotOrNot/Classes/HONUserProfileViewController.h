//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONUserProfileViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>
- (id)initWithBackground:(UIImageView *)imageView;
@property (nonatomic) int userID;
@end
