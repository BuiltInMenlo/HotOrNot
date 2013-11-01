//
//  HONVerifyCellHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/31/13 @ 10:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyCellHeaderView.h"


@interface HONVerifyCellHeaderView ()
@property (nonatomic, retain) HONOpponentVO *opponentVO;
@end

@implementation HONVerifyCellHeaderView
@synthesize delegate = _delegate;

- (id)initWithOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)])) {
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
		_opponentVO = opponentVO;
		
		
		NSMutableString *avatarURL = [_opponentVO.imagePrefix mutableCopy];
		[avatarURL replaceOccurrencesOfString:@".jpg" withString:@"Small_160x160.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:nil];
		[self addSubview:avatarImageView];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 5.0, 220.0, 22.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		nameLabel.text = [NSString stringWithFormat:@"%@ is new", _opponentVO.username];
		[self addSubview:nameLabel];
		
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 22.0, 240.0, 22.0)];
		messageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		messageLabel.shadowOffset =  CGSizeMake(1.0, 1.0);
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.text = [HONAppDelegate verifyHeaderMessage];
		[self addSubview:messageLabel];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate cellHeaderView:self showProfileForUser:_opponentVO];
}



@end
