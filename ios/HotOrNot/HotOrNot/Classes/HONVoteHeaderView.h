//
//  HONVoteHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@interface HONVoteHeaderView : UIView

@property (nonatomic, strong) HONChallengeVO *challengeVO;

- (id)initWithFrame:(CGRect)frame asPush:(BOOL)isPush;
@end
