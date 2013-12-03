//
//  HONEmptyChallengeViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONEmptyChallengeViewCellDelegate;
@interface HONEmptyChallengeViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, assign) id <HONEmptyChallengeViewCellDelegate> delegate;
@end

@protocol HONEmptyChallengeViewCellDelegate
- (void)emptyChallengeViewCellShowFrinds:(HONEmptyChallengeViewCell *)cell;
@end