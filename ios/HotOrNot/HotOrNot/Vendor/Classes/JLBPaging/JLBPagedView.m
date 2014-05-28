//
//  JLBPagedView.m
//  NavigationTest
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import "JLBPagedView.h"

@implementation JLBPagedView
{
	NSUInteger _numberOfItems;
	NSMutableIndexSet *_visibleIndexes;
	NSMutableDictionary *_visibleItems;
	NSMapTable *_itemToViewController;
	NSMutableSet *_enqueuedViewControllers;
	
	NSMutableDictionary *_registeredReuseIdentifiers;
	
	UIViewController *_appearingViewController;
	UIViewController *_disappearingViewController;
	
	BOOL _layoutSubviewsReentrancyGuard;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.pagingEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		_visibleItems = [NSMutableDictionary new];
		_itemToViewController = [NSMapTable strongToStrongObjectsMapTable];
		_enqueuedViewControllers = [NSMutableSet new];
	}
	return self;
}

- (NSInteger)currentPageIndex
{
	//return [self _indexForVisiblePageAtOffset:self.contentOffset.x];
	return [self _indexForVisiblePageAtOffset:self.contentOffset.y];
}

- (CGRect)rectForIndex:(NSUInteger)index
{
	CGRect bounds = self.bounds;
	//return CGRectMake(CGRectGetWidth(bounds) * index, 0.0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
	return CGRectMake(0.0, CGRectGetHeight(bounds) * index, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
}

- (CGRect)rectForItem:(id)item
{
	CGRect rect = CGRectZero;
	NSArray *indexes = [_visibleItems allKeysForObject:item];
	if ([indexes count] == 1)
		rect = [self rectForIndex:[indexes[0] unsignedIntegerValue]];
	return rect;
}

- (NSInteger)_indexForVisiblePageAtOffset:(CGFloat)offset
{
	//return MAX(0.0, offset) / self.bounds.size.width;
	return MAX(0.0, offset) / self.bounds.size.height;
}

#pragma mark - Data Source

- (void)reloadData
{
	[self _reloadDataMaintainingVisibleIndex:[self _indexForVisiblePageAtOffset:self.contentOffset.x]];
}

- (void)_reloadDataMaintainingVisibleIndex:(NSInteger)index
{
	[self _invalidateAllItems];
	_numberOfItems = [_dataSource numberOfItemsForPagedView:self];
	_visibleIndexes = [NSMutableIndexSet indexSet];
	//self.contentSize = CGSizeMake(self.bounds.size.width * _numberOfItems, self.bounds.size.height);
	self.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * _numberOfItems);
	
	if (!_layoutSubviewsReentrancyGuard) {
		// @revisit maintain index
		self.contentOffset = CGPointMake(0.0, 0.0);
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

#pragma mark - Layout

- (void)layoutSubviews
{
	if (!_layoutSubviewsReentrancyGuard) {
		_layoutSubviewsReentrancyGuard = YES;
		
		[UIView performWithoutAnimation:^{
			if (_visibleIndexes == nil)
				[self reloadData];
			
			[super layoutSubviews]; // update contentOffset
			
			[self _layoutItems];
		}];
		_layoutSubviewsReentrancyGuard = NO;
	}
}

- (void)_layoutItems
{
	NSMutableIndexSet *currentlyVisibleIndexes = [_visibleIndexes mutableCopy];
	[_visibleIndexes removeAllIndexes];
	
	//NSInteger visibleIndex = [self _indexForVisiblePageAtOffset:self.contentOffset.x];
	NSInteger visibleIndex = [self _indexForVisiblePageAtOffset:self.contentOffset.y];
	NSRange visibleRange = NSMakeRange(0, 0);
	
	if (_numberOfItems > 0) {
		// Extend the visible range by 2 in both directions if possible
		NSUInteger previousIndex = visibleIndex;
		if (previousIndex > 0)
			previousIndex--;
		if (previousIndex > 0)
			previousIndex--;
		NSUInteger nextIndex = MIN(_numberOfItems - 1, visibleIndex + 2);
		visibleRange = NSMakeRange(previousIndex, nextIndex - previousIndex);
	}
	
	if (visibleRange.length > 0) {
		for (NSUInteger i = visibleRange.location; i <= NSMaxRange(visibleRange); i++) {
			id key = @(i);
			id item = [_visibleItems objectForKey:key];
			if (item == nil) {
				// Dequeue a new view controller from the data source
				id item = [_dataSource pagedView:self itemAtIndex:i];
				NSParameterAssert(item != nil);
				[_visibleItems setObject:item forKey:key];
				
				UIViewController *itemViewController = [_dataSource pagedView:self viewControllerForItem:item atIndex:i];
				NSAssert(itemViewController != nil, @"-pagedView:viewControllerForItem:atIndex: must return a non-nil view controller.");
				itemViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				if ([itemViewController respondsToSelector:@selector(setPageItem:)])
					[(id<JLBPagedItemViewController>)itemViewController setPageItem:item];
				[_itemToViewController setObject:itemViewController forKey:item];
				
				[UIView performWithoutAnimation:^{
					itemViewController.view.frame = [self rectForIndex:i];
					[self insertSubview:itemViewController.view atIndex:0];
				}];
			}
			else {
				[currentlyVisibleIndexes removeIndex:i];
			}
			[_visibleIndexes addIndex:i];
		}
	}
	
	// Remove any items that should no longer be visible
	if ([currentlyVisibleIndexes count] > 0) {
		for (NSUInteger i = [currentlyVisibleIndexes firstIndex]; i <= [currentlyVisibleIndexes lastIndex]; i = [currentlyVisibleIndexes indexGreaterThanIndex:i]) {
			id key = @(i);
			id deadItem = _visibleItems[key];
			UIViewController *deadViewController = [_itemToViewController objectForKey:deadItem];
			[self _reclaimItemViewController:deadViewController];
			[deadViewController.view removeFromSuperview];
			[_itemToViewController removeObjectForKey:deadItem];
			[_visibleItems removeObjectForKey:key];
		}
	}
}

#pragma mark - View Controller Reuse

- (void)registerClass:(Class)viewControllerClass forViewControllerReuseIdentifier:(NSString *)identifier
{
	NSParameterAssert(viewControllerClass != nil);
	NSParameterAssert(identifier != nil);
	
	if (_registeredReuseIdentifiers == nil)
		_registeredReuseIdentifiers = [NSMutableDictionary new];
	[_registeredReuseIdentifiers setObject:viewControllerClass forKey:identifier];
}

- (id)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier forIndex:(NSUInteger)index
{
	NSParameterAssert(identifier != nil);
	
	UIViewController *itemViewController = [self _dequeueItemViewControllerWithIdentifier:identifier];
	if (itemViewController == nil) {
		Class itemViewControllerClass = [_registeredReuseIdentifiers objectForKey:identifier];
		NSAssert(itemViewControllerClass != nil, @"You must register a view controller class for reuse identifier %@ before using it", identifier);
		itemViewController = [[itemViewControllerClass alloc] init];
	}
	return itemViewController;
}

- (void)_invalidateAllItems
{
	[self _recycleAllVisibleItems];
	_visibleIndexes = nil;
}

- (void)_reclaimItemViewController:(UIViewController *)itemViewController
{
	if ([itemViewController respondsToSelector:@selector(reuseIdentifier)]) {
		if ([itemViewController respondsToSelector:@selector(itemViewControllerWillBeReclaimed)])
			[(id<JLBPagedItemViewController>)itemViewController itemViewControllerWillBeReclaimed];
		[self _enqueueItemViewController:itemViewController];
	}
}

- (void)_recycleAllVisibleItems
{
	for (id item in [_visibleItems allValues]) {
		UIViewController *itemViewController = [_itemToViewController objectForKey:item];
		[self _reclaimItemViewController:itemViewController];
	}
	[_visibleItems removeAllObjects];
	[_itemToViewController removeAllObjects];
}

- (UIViewController *)_dequeueItemViewControllerWithIdentifier:(NSString *)identifier
{
	UIViewController *itemViewController = nil;
	for (UIViewController *viewController in _enqueuedViewControllers) {
		if ([[(id<JLBPagedItemViewController>)viewController reuseIdentifier] isEqualToString:identifier]) {
			itemViewController = viewController;
			break;
		}
	}
	
	if (itemViewController != nil)
		[_enqueuedViewControllers removeObject:itemViewController];
	
	return itemViewController;
}

- (void)_enqueueItemViewController:(UIViewController *)itemViewController
{
	if (itemViewController != nil)
		[_enqueuedViewControllers addObject:itemViewController];
}

@end
