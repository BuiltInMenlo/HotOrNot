//
//  HONChallengerPickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONChallengerPickerViewController : UIViewController
- (id)initWithImage:(UIImage *)img subjectName:(NSString *)subject;
- (id)initWithFlippedImage:(UIImage *)img subjectName:(NSString *)subject;
@end
