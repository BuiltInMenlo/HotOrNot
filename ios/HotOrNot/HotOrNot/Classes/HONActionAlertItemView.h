//
//  HONActionAlertItemView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 10:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONAlertItemVO.h"

@protocol HONActionAlertItemViewDelegate;
@interface HONActionAlertItemView : UIView

@property (nonatomic, assign) id <HONActionAlertItemViewDelegate> delegate;
@property (nonatomic, retain) HONAlertItemVO *actionAlertItemVO;
@end


@protocol HONActionAlertItemViewDelegate <NSObject>
- (void)alertActionItemView:(HONActionAlertItemView *)actionAlertItemView alertActionItem:(HONAlertItemVO *)actionAlertItemVO;
@end
