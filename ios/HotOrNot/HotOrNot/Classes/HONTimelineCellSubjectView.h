//
//  HONTimelineCellSubjectView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 12/08/2013 @ 15:31 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONTimelineCellSubjectViewDelegate;
@interface HONTimelineCellSubjectView : UIView
- (id)initAtOffsetY:(CGFloat)offsetY withSubjectName:(NSString *)subjectName withUsername:(NSString *)username;

@property (nonatomic, assign) id <HONTimelineCellSubjectViewDelegate> delegate;
@end


@protocol HONTimelineCellSubjectViewDelegate <NSObject>
- (void)timelineCellSubjectViewShowProfile:(HONTimelineCellSubjectView *)subjectView;
@end
