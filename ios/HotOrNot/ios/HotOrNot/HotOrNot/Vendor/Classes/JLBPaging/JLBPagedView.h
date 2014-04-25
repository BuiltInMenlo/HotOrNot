//
//  JLBPagedView.h
//  NavigationTest
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLBPagedView;

@protocol JLBPagedViewControllerDataSource <NSObject>
- (NSUInteger)numberOfItemsForPagedView:(JLBPagedView *)pagedView;
- (id)pagedView:(JLBPagedView *)pagedView itemAtIndex:(NSUInteger)index;
- (id)pagedView:(JLBPagedView *)pagedView viewControllerForItem:(id)item atIndex:(NSUInteger)index;
@end

@interface JLBPagedView : UIScrollView
@property(nonatomic, weak) NSObject<JLBPagedViewControllerDataSource> *dataSource;

- (void)reloadData;

- (void)registerClass:(Class)viewControllerClass forViewControllerReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier forIndex:(NSUInteger)index;

- (NSInteger)currentPageIndex;
@end

@protocol JLBPagedItemViewController <NSObject>
// If a reuseIdentifier is specified, the item view controller is elgible for reuse
- (NSString *)reuseIdentifier;
- (void)itemViewControllerWillBeReclaimed;

// The item is passed to the view controller for the page using the following method (if implemented)
- (void)setPageItem:(id)pageItem;
@end