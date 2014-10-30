//
//  HONTableViewBGView.h
//  HotOrNot
//
//  Created by BIM  on 10/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HONTableViewBGViewType) {
	HONTableViewBGViewTypeUndetermined = 0,
	HONTableViewBGViewTypeAccessContacts,
	HONTableViewBGViewTypeCreateStatusUpdate
};

@class HONTableViewBGView;
@protocol HONTableViewBGViewDelegate <NSObject>
@optional
- (void)tableViewBGViewDidSelect:(HONTableViewBGView *)bgView;
@end

@interface HONTableViewBGView : UIView
- (id)initAsType:(HONTableViewBGViewType)type withCaption:(NSString *)caption usingTarget:(id)target action:(SEL)action;

@property (nonatomic) HONTableViewBGViewType viewType;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic, assign) id <HONTableViewBGViewDelegate> delegate;
@end
