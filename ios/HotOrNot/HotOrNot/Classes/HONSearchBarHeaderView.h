//
//  HONSearchBarHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@protocol HONSearchBarHeaderViewDelegate;
@interface HONSearchBarHeaderView : UIView <UITextFieldDelegate>
- (void)toggleFocus:(BOOL)isFocused;
- (void)backgroundingReset;

@property(nonatomic, assign) id <HONSearchBarHeaderViewDelegate> delegate;
@end


@protocol HONSearchBarHeaderViewDelegate <NSObject>
- (void)searchBarHeaderFocus:(HONSearchBarHeaderView *)searchBarHeaderView;
- (void)searchBarHeaderCancel:(HONSearchBarHeaderView *)searchBarHeaderView;
- (void)searchBarHeader:(HONSearchBarHeaderView *)searchBarHeaderView enteredSearch:(NSString *)searchQuery;
@end