//
//  HONStatusUpdateCreatorView.h
//  HotOrNot
//
//  Created by BIM  on 1/7/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONStatusUpdateVO.h"

@class HONStatusUpdateCreatorView;
@protocol HONStatusUpdateCreatorViewDelegate <NSObject>
- (void)statusUpdateCreatorViewDidDownVote:(HONStatusUpdateCreatorView *)statusUpdateCreatorView;
- (void)statusUpdateCreatorViewDidUpVote:(HONStatusUpdateCreatorView *)statusUpdateCreatorView;
@optional
- (void)statusUpdateCreatorViewOpenAppStore:(HONStatusUpdateCreatorView *)statusUpdateCreatorView;
@end

@interface HONStatusUpdateCreatorView : UIView
- (id)initWithStatusUpdateVO:(HONStatusUpdateVO *)statusUpdateVO;
- (void)refreshScore;

@property (nonatomic, assign) id <HONStatusUpdateCreatorViewDelegate> delegate;
@end
