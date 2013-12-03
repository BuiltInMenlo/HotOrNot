//
//  HONRegisterCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/5/13 @ 4:27 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONRegisterCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initWithPassword:(NSString *)password andBirthday:(NSString *)birthday;
@end
