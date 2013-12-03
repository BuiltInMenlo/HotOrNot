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

- (id)initWithFrame:(CGRect)frame AsComposeSubjects:(BOOL)isCompose;

@property (nonatomic, assign) id <HONCameraSubjectsViewDelegate> delegate;
@property (nonatomic) BOOL isJoinVolley;
@end

@protocol HONCameraSubjectsViewDelegate
- (void)subjectsView:(HONCameraSubjectsView *)cameraSubjectsView selectSubject:(NSString *)subject;
@end
