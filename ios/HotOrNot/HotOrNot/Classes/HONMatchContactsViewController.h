//
//  HONMatchContactsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONMatchContactsViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
- (id)initAsEmailVerify:(BOOL)isEmail;
@end
