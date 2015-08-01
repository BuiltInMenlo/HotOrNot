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
		[self hideChevron];
		
		_thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
		_thumbImageView.image = [UIImage imageNamed:@"placeholderClubPhoto_160x160"];
		//[self.contentView addSubview:_thumbImageView];
	}
	
	return (self);
}


- (void)populateFields:(NSDictionary *)dictionary {
	
	NSString *caption = ([[dictionary objectForKey:@"title"] isEqualToString:@"Feedback"] || [[dictionary objectForKey:@"title"] isEqualToString:@"New People"]) ? [dictionary objectForKey:@"title"] : [NSString stringWithFormat:@"%@-%@", [[[dictionary objectForKey:@"title"] componentsSeparatedByString:@"-"] firstObject], [[[dictionary objectForKey:@"title"] componentsSeparatedByString:@"_"] lastObject]];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 7.0, 252.0, 28.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = caption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 252.0, 28.0)];
	participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	participantsLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.text = [NSString stringWithFormat:@"%@%@ with %d %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]], ([[[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]] isEqualToString:@"Just now"]) ? @"" : @" ago", [[dictionary objectForKey:@"occupants"] intValue], ([[dictionary objectForKey:@"occupants"] intValue] == 1) ? @"person" : @"people"];
	[self.contentView addSubview:participantsLabel];
}


@end
