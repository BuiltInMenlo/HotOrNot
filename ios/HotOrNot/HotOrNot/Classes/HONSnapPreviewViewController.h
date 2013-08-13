//
//  HONSnapPreviewViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONOpponentVO.h"

@interface HONSnapPreviewViewController : UIViewController
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithOpponent:(HONOpponentVO *)vo;
- (id)initWithImageURL:(NSString *)url;
@end
