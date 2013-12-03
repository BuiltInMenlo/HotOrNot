//
//  HONChallengerPickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONUserVO.h"

@interface HONChallengerPickerViewController : UIViewController
- (id)initWithSubject:(NSString *)subject imagePrefix:(NSString *)imgPrefix previewImage:(UIImage *)image;
- (id)initWithSubject:(NSString *)subject imagePrefix:(NSString *)imgPrefix previewImage:(UIImage *)image userVO:(HONUserVO *)userVO challengeVO:(HONChallengeVO *)challengeVO;
@end
