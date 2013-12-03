//
//  HONCameraPreviewSubscribersView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONCameraSubjectsViewDelegate;
@interface HONCameraPreviewSubscribersView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *opponents;
@property(nonatomic, assign) id <HONCameraSubjectsViewDelegate> delegate;
@end

@protocol HONCameraSubjectsViewDelegate
- (void)subscriberView:(HONCameraPreviewSubscribersView *)cameraPreviewSubscribersView removeOpponent:(HONUserVO *)userVO;
@end
