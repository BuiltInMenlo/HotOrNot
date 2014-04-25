//
//  HONClubTimelineViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 11:00 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubTimelineViewCell.h"

@interface HONClubTimelineViewCell ()
@property (nonatomic) BOOL isCTACell;
@end

@implementation HONClubTimelineViewCell
@synthesize userClubVO = _userClubVO;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initAsCTARow:(BOOL)isCTARow {
	if ((self = [super init])) {
		_isCTACell = isCTARow;
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)didSelect {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellSelectedBG"]];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)setUserClubVO:(HONUserClubVO *)userClubVO {
	_userClubVO = userClubVO;
}


#pragma mark - UI Presentation
- (void)_resetBG {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
}


@end
