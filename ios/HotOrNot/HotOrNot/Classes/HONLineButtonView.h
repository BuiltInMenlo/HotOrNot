//
//  HONLineButtonView.h
//  HotOrNot
//
//  Created by BIM  on 10/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HONLineButtonViewType) {
	HONLineButtonViewTypeUndetermined = 0,
	HONLineButtonViewTypeRegister,
	HONLineButtonViewTypePINEntry,
	HONLineButtonViewTypeAccessContacts,
	HONLineButtonViewTypeCreateStatusUpdate
};

@class HONLineButtonView;
@protocol HONLineButtonViewDelegate <NSObject>
@optional
- (void)lineButtonViewDidSelect:(HONLineButtonView *)lineButtonView;
@end

@interface HONLineButtonView : UIView
- (id)initAsType:(HONLineButtonViewType)type withCaption:(NSString *)caption usingTarget:(id)target action:(SEL)action;

@property (nonatomic) HONLineButtonViewType viewType;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic, assign) id <HONLineButtonViewDelegate> delegate;
@end
