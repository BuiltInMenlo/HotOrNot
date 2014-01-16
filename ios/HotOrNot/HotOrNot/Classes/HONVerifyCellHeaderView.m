//
//  HONFollowTabCellHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 1:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyCellHeaderView.h"
#import "HONAPICaller.h"


@interface HONVerifyCellHeaderView ()
@property (nonatomic, retain) HONOpponentVO *opponentVO;
@property (nonatomic, strong) NSDictionary *verifyTabInfo;
@end

@implementation HONVerifyCellHeaderView

@synthesize delegate = _delegate;

- (id)initWithOpponent:(HONOpponentVO *)opponentVO {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)])) {
//		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
		_opponentVO = opponentVO;
		
		_verifyTabInfo = [HONAppDelegate infoForABTab];
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
		[self addSubview:avatarImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			avatarImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:_opponentVO.imagePrefix completion:nil];
		};
		
		[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_opponentVO.imagePrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = avatarImageView.frame;
		[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
		
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(51.0, 8.0, 220.0, 19.0)];
		nameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:13];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.text = [NSString stringWithFormat:[[HONAppDelegate infoForABTab] objectForKey:@"name_format"], _opponentVO.username];
		[self addSubview:nameLabel];
//
//		CGSize size = [nameLabel.text boundingRectWithSize:CGSizeMake(220.0, 22.0)
//												   options:NSStringDrawingTruncatesLastVisibleLine
//												attributes:@{NSFontAttributeName:nameLabel.font}
//												   context:nil].size;
//		nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, size.width, nameLabel.frame.size.height);
		
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(51.0, 25.0, 265.0, 17.0)];
		messageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.text = [NSString stringWithFormat:[[HONAppDelegate infoForABTab] objectForKey:@"cta_txt"], _opponentVO.username];
		[self addSubview:messageLabel];
		
//		UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		nameButton.frame = nameLabel.frame;
//		[nameButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:nameButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate cellHeaderView:self showProfileForUser:_opponentVO];
}


@end
