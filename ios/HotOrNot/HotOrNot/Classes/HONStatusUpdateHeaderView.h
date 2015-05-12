//
//  HONStatusUpdateHeaderView.h
//  HotOrNot
//
//  Created by BIM  on 1/7/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONStatusUpdateVO.h"

@class HONStatusUpdateHeaderView;
@protocol HONStatusUpdateHeaderViewDelegate <NSObject>
- (void)statusUpdateHeaderViewGoBack:(HONStatusUpdateHeaderView *)statusUpdateHeaderView;
@optional
- (void)statusUpdateHeaderViewChangeCamera:(HONStatusUpdateHeaderView *)statusUpdateHeaderView;
- (void)statusUpdateHeaderViewCopyLink:(HONStatusUpdateHeaderView *)statusUpdateHeaderView;
- (void)statusUpdateHeaderViewFlag:(HONStatusUpdateHeaderView *)statusUpdateHeaderView;
@end

@interface HONStatusUpdateHeaderView : UIView
- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO;
- (void)changeTitle:(NSString *)title;

@property (nonatomic, assign) id <HONStatusUpdateHeaderViewDelegate> delegate;
@end
