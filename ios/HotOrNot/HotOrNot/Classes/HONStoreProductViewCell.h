//
//  HONStoreProductViewCell.h
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONStoreProductVO.h"

@interface HONStoreProductViewCell : HONTableViewCell
@property (nonatomic, retain) HONStoreProductVO *storeProductVO;
@property (nonatomic) BOOL isPurchased;
@end
