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
	}
	
	return (self);
}


- (void)populateFields:(NSDictionary *)dictionary {
	
	_thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.height, self.frame.size.height)];
	_thumbImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Channel", (self.indexPath.section == 0) ? @"friends" : (self.indexPath.section == 1 && self.indexPath.row == 0) ? @"music" : (self.indexPath.section == 1 && self.indexPath.row == 1) ? @"games" : (self.indexPath.section == 1 && self.indexPath.row == 2) ? @"explore" : @"user"]];
	[self.contentView addSubview:_thumbImageView];
	
	NSString *caption = (self.indexPath.section == 2) ? [NSString stringWithFormat:@"%d %@", [[dictionary objectForKey:@"occupants"] intValue], ([[dictionary objectForKey:@"occupants"] intValue] == 1) ? @"person" : @"people"] : [dictionary objectForKey:@"title"];//(self.indexPath.section == 1) ? [dictionary objectForKey:@"title"] : ([dictionary objectForKey:@"url"] != nil) ? [[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@""] : @"pp1.link/…";
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height + 12.0, 12.0, self.frame.size.width - 24.0, 28.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] avenirHeavy] fontWithSize:24];
	titleLabel.textColor = [UIColor colorWithRed:0.278 green:0.243 blue:0.243 alpha:1.00];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = caption;
	[self.contentView addSubview:titleLabel];
	
	UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height + 12.0, 36.0, self.frame.size.width - 24.0, 28.0)];
	participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	participantsLabel.textColor = [UIColor colorWithWhite:0.718 alpha:1.00];
	participantsLabel.backgroundColor = [UIColor clearColor];
	participantsLabel.text = [NSString stringWithFormat:@"%@%@ %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]], ([[[HONDateTimeAlloter sharedInstance] intervalSinceDate:[dictionary objectForKey:@"timestamp"]] isEqualToString:@""]) ? @"" : @" ago", [[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
	[self.contentView addSubview:participantsLabel];
}


@end
