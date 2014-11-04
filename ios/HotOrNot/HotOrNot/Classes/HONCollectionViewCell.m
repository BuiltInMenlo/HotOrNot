//
//  HONCollectionViewCell.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewCell.h"

@implementation HONCollectionViewCell
@synthesize indexPath = _indexPath;
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setIndexPath:(NSIndexPath *)indexPath {
	_indexPath = indexPath;
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(collectionViewCellDidSelect:)])
		[self.delegate collectionViewCellDidSelect:self];
}

@end
