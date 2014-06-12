//
//  HONFeedViewController.h
//  HotOrNot
//
//  Created by Jesse Boley on 2/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "JLBPagedViewController.h"

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@interface HONFeedViewController : JLBPagedViewController
//@property(nonatomic, strong) NSArray *challenges;<<
@property(nonatomic, strong) HONUserClubVO *clubVO;
@end
