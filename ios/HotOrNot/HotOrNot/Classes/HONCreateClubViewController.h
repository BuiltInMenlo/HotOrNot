//
//  HONCreateClubViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONViewController.h"

@interface HONCreateClubViewController : HONViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
- (id)initWithClubTitle:(NSString *)title;
@end
