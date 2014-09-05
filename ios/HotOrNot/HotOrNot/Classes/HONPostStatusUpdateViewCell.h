//
//  HONPostStatusUpdateViewCell.h
//  HotOrNot
//
//  Created by Anirudh Agarwala on 9/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"

@interface HONPostStatusUpdateViewCell : HONTableViewCell

- (id)initWithCaption:(NSString *)caption;

@property (nonatomic, strong) NSString *caption;

@end
