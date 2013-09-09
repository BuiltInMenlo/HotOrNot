//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@interface HONUserProfileViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) HONUserVO *userVO;

- (id)initWithBackground:(UIImageView *)imageView;
@end
