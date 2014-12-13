//
//  HONComposeViewCell.h
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCollectionViewCell.h"
#import "HONComposeImageVO.h"

@class HONComposeViewCell;
@protocol HONComposeViewCellDelegate <HONCollectionViewCellDelegate>
@optional
- (void)composeViewCell:(HONComposeViewCell *)viewCell didSelectComposeImage:(HONComposeImageVO *)composeImageVO;
@end

@interface HONComposeViewCell : HONCollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONComposeImageVO *composeImageVO;
@property (nonatomic, assign) id <HONComposeViewCellDelegate> delegate;
@end
