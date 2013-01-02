//
//  HONChallengePreviewViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.01.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@interface HONChallengePreviewViewController : UIViewController

- (id)initAsCreator:(HONChallengeVO *)vo;
- (id)initAsChallenger:(HONChallengeVO *)vo;

@end
