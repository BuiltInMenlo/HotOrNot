//
//  HONSearchBarView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@protocol HONSearchBarViewDelegate;
@interface HONSearchBarView : UIView <UITextFieldDelegate>
- (void)backgroundingReset;

@property(nonatomic, assign) id <HONSearchBarViewDelegate> delegate;
@end


@protocol HONSearchBarViewDelegate <NSObject>
- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView;
- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery;
@optional
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView;
@end