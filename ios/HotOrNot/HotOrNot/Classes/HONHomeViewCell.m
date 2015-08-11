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
	
//	NSString *caption = ([[dictionary objectForKey:@"title"] isEqualToString:@"Feedback"] || [[dictionary objectForKey:@"title"] isEqualToString:@"New People"]) ? [dictionary objectForKey:@"title"] : ([dictionary objectForKey:@"url"] != nil) ? [[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@""] : @"pp1.link/…";
	NSString *caption = [dictionary objectForKey:@"title"];//(self.indexPath.section == 1) ? [dictionary objectForKey:@"title"] : ([dictionary objectForKey:@"url"] != nil) ? [[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@""] : @"pp1.link/…";
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, self.frame.size.width - 50.0, 28.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] avenirHeavy] fontWithSize:24];
	titleLabel.textColor = [UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = caption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 36.0, self.frame.size.width - 50.0, 28.0)];
	participantsLabel.font = [[[HONFontAllocator sharedInstance] avenirHeavy] fontWithSize:15];
	participantsLabel.textColor = [UIColor blackColor];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.text = (self.indexPath.section == 1) ? [NSString stringWithFormat:@"%d %@", [[dictionary objectForKey:@"occupants"] intValue], ([[dictionary objectForKey:@"occupants"] intValue] == 1) ? @"person" : @"people"] : [NSString stringWithFormat:@"%@%@, %d %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]], ([[[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]] isEqualToString:@"Just now"]) ? @"" : @" ago", [[dictionary objectForKey:@"occupants"] intValue], ([[dictionary objectForKey:@"occupants"] intValue] == 1) ? @"person" : @"people"];
	[self.contentView addSubview:participantsLabel];
}


@end
