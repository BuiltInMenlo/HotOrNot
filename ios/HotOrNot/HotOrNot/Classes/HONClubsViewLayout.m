//
//  HONClubsViewLayout.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 19:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubsViewLayout.h"

const CGSize kClubCollectionViewSize = {160.0, 198.0};

@implementation HONClubsViewLayout

- (id)init {
	if ((self = [super init])) {
		self.itemSize = kClubCollectionViewSize;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumInteritemSpacing = 0.0;
		self.minimumLineSpacing = 0.0;
	}
	
	return (self);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return (YES);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *array = [super layoutAttributesForElementsInRect:rect];
	
	CGRect visibleRect;
	visibleRect.origin = self.collectionView.contentOffset;
	visibleRect.size = self.collectionView.bounds.size;
	
	return (array);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
	CGFloat offsetAdjustment = MAXFLOAT;
	CGFloat hCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) * 0.5);
	
	for (UICollectionViewLayoutAttributes *layoutAtrtributes in [super layoutAttributesForElementsInRect:CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)]) {
		CGFloat hItemCenter = layoutAtrtributes.center.x;
		if (ABS(hItemCenter - hCenter) < ABS(offsetAdjustment))
			offsetAdjustment = hItemCenter - hCenter;
	}
	
	return (CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y));
}

@end
