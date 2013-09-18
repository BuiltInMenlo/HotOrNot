//
//  HONCollectionViewFlowLayout.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/17/13 @ 9:15 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewFlowLayout.h"

@implementation HONCollectionViewFlowLayout {
	UIDynamicAnimator *_dynamicAnimator;
}

-(void)prepareLayout {
	[super prepareLayout];
	
	if (!_dynamicAnimator) {
		_dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
		
		CGSize contentSize = [self collectionViewContentSize];
		NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0.0, 0.0, contentSize.width, contentSize.height)];
		
		for (UICollectionViewLayoutAttributes *item in items) {
			UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:[item center]];
			spring.length = 0.0;
			spring.damping = 0.5;
			spring.frequency = 0.8;
			
			[_dynamicAnimator addBehavior:spring];
		}
	}
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	return ([_dynamicAnimator itemsInRect:rect]);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return ([_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath]);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	UIScrollView *scrollView = self.collectionView;
	
	CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
	CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
	
	for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors) {
		CGFloat resist = fabsf(touchLocation.y - spring.anchorPoint.y) / 750;
		
		UICollectionViewLayoutAttributes *item = [spring.items firstObject];
		CGPoint centerPt = item.center;
//		centerPt.y += MIN(delta, delta * resist);
		centerPt.y += delta * resist;
		item.center = centerPt;
		
		[_dynamicAnimator updateItemUsingCurrentState:item];
	}
	
	return (NO);
}

@end
