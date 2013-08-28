//
//  HONCameraPreviewSubscribersView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONCameraPreviewSubscribersViewDelegate;
@interface HONCameraPreviewSubscribersView : UIView

@property (nonatomic, retain) NSMutableArray *opponents;
@property(nonatomic, assign) id <HONCameraPreviewSubscribersViewDelegate> delegate;
@end

@protocol HONCameraPreviewSubscribersViewDelegate
- (void)subscriberView:(HONCameraPreviewSubscribersView *)cameraPreviewSubscribersView removeOpponent:(HONUserVO *)userVO;
@end
