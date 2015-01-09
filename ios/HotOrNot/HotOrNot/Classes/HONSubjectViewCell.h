//
//  HONSubjectViewCell.h
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONSubjectVO.h"

@class HONSubjectViewCell;
@protocol HONSubjectViewCellDeleagte <HONTableViewCellDelegate>
@optional
- (void)subjectViewCell:(HONSubjectViewCell *)viewCell didSelectSubject:(HONSubjectVO *)subjectVO;
@end

@interface HONSubjectViewCell : HONTableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)toggleImageLoading:(BOOL)isLoading;

@property (nonatomic, retain) HONSubjectVO *subjectVO;
@property (nonatomic, assign) id <HONSubjectViewCellDeleagte> delegate;

@end
