//
//  HONImageTypeViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONImageTypeViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;


@property (nonatomic, strong) NSString *caption;
@property (nonatomic) int total;

@end
