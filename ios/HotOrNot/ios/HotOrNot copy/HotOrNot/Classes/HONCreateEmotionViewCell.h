//
//  HONCameraSubjectViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONEmotionVO.h"

@interface HONCreateEmotionViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initWithEmotion:(HONEmotionVO *)emotionVO AsEvenRow:(BOOL)isEven;
- (void)showTapOverlay;
@end
