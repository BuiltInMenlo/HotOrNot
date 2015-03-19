//
//  HONStatusUpdateFooterView.h
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@class HONStatusUpdateFooterView;
@protocol HONStatusUpdateFooterViewDelegate <NSObject>
- (void)statusUpdateFooterViewEnterComment:(HONStatusUpdateFooterView *)statusUpdateFooterView;
- (void)statusUpdateFooterViewShowShare:(HONStatusUpdateFooterView *)statusUpdateFooterView;
@optional
- (void)statusUpdateFooterViewTakePhoto:(HONStatusUpdateFooterView *)statusUpdateFooterView;
@end

@interface HONStatusUpdateFooterView : UIView
- (void)toggleTakePhotoButton:(BOOL)isEnabled;

@property (nonatomic, assign) id <HONStatusUpdateFooterViewDelegate> delegate;
@end
