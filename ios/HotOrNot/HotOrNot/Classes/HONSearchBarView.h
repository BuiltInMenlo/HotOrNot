//
//  HONSearchBarView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@class HONSearchBarView;
@protocol HONSearchBarViewDelegate <NSObject>
- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView;
- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery;
@optional
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView;
@end

@interface HONSearchBarView : UIView <UITextFieldDelegate>
- (id)initAsHighSchoolSearchWithFrame:(CGRect)frame;
- (void)backgroundingReset;

@property(nonatomic, assign) id <HONSearchBarViewDelegate> delegate;
-(id) initAsHighSchoolWithFrame:(CGRect) frame;
@end
