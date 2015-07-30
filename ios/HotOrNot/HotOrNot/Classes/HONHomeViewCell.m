//
//  HONHomeViewCell.m
//  HotOrNot
//
//  Created by BIM  on 7/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltInMenlo.h"

#import "HONHomeViewCell.h"

@interface HONHomeViewCell ()
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UIButton *linkButton;
@end

@implementation HONHomeViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
	}
	
	[self hideChevron];
	
	_thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
	_thumbImageView.image = [UIImage imageNamed:@"placeholderClubPhoto_160x160"];
	[self.contentView addSubview:_thumbImageView];
	
	return (self);
}


- (void)populateFields:(NSDictionary *)dictionary {
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(69.0, 7.0, 252.0, 28.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [dictionary objectForKey:@"title"];
	[self.contentView addSubview:titleLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0, titleLabel.frame.origin.y, 40.0, titleLabel.frame.size.height)];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [dictionary objectForKey:@"timestamp"];
	[self.contentView addSubview:timeLabel];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(69.0, 30.0, 252.0, 28.0)];
	participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	participantsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.text = [dictionary objectForKey:@"occupants"];
	[self.contentView addSubview:participantsLabel];
}


@end
