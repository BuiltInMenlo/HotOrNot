//
//  HONTimelineSubjectViewCell.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONTimelineSubjectViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (id)initWithSubject:(NSString *)subject;

#define kImgSize 100.0

@property (nonatomic) int subjectID;
@property (nonatomic) int index;
@property (nonatomic, retain) NSMutableArray *challenges;
@property (nonatomic, retain) NSString *subject;

@end
