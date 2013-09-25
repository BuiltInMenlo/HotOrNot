//
//  HONCameraSubjectsView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"

@protocol HONCameraSubjectsViewDelegate;
@interface HONCameraSubjectsView : UIView <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, assign) id <HONCameraSubjectsViewDelegate> delegate;
@end

@protocol HONCameraSubjectsViewDelegate
- (void)subjectsView:(HONCameraSubjectsView *)cameraSubjectsView selectSubject:(NSString *)subject;
@end
