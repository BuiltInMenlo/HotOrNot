//
//  GSMessengerViewCellCollectionViewCell.h
//  HotOrNot
//
//  Created by BIM  on 6/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSMessengerVO.h"
#import "GSMessenger.h"

@class GSCollectionViewCell;
@protocol GSCollectionViewCellDelegate <NSObject>
@optional
- (void)collectionViewCell:(GSCollectionViewCell *)viewCell didSelectMessgenger:(GSMessengerVO *)vo;
@end


@interface GSCollectionViewCell : UICollectionViewCell
+ (NSString *)cellReuseIdentifier;
- (void)destroy;

@property (nonatomic) CGSize size;
@property (nonatomic, readonly, getter=isContentVisible) BOOL contentVisible;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id <GSCollectionViewCellDelegate> delegate;
@property (nonatomic, retain) GSMessengerVO *messengerVO;
@property (nonatomic) GSMessengerType messengerType;
@end
