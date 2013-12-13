//
//  HONEmptyTimelineView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/25/13 @ 12:43 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONEmptyTimelineViewDelegate;
@interface HONEmptyTimelineView : UIView
@property (nonatomic, assign) id <HONEmptyTimelineViewDelegate> delegate;
@end

@protocol HONEmptyTimelineViewDelegate <NSObject>
- (void)emptyTimelineViewVerify:(HONEmptyTimelineView *)emptyTimelineView;
@end