//
//  HONCallingCodeViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/09/2014 @ 15:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONCountryVO.h"

@class HONCallingCodeViewCell;
@protocol HONCallingCodeViewCellDelegate <NSObject>
- (void)callingCodeViewCell:(HONCallingCodeViewCell *)viewCell didDeselectCountry:(HONCountryVO *)countryVO;
- (void)callingCodeViewCell:(HONCallingCodeViewCell *)viewCell didSelectCountry:(HONCountryVO *)countryVO;
@end

@interface HONCallingCodeViewCell : HONTableViewCell
- (void)invertSelected;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, retain) HONCountryVO *countryVO;
@property (nonatomic, assign) id <HONCallingCodeViewCellDelegate> delegate;
@end
