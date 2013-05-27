//
//  HONInviteViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 5/25/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONInviteViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (void)setContents:(NSDictionary *)dict;
@end
