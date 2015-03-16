//
//  HONChannelInviteButtonView.h
//  HotOrNot
//
//  Created by BIM  on 3/15/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HONChannelInviteButtonType) {
	HONChannelInviteButtonTypeClipboard = 0,
	HONChannelInviteButtonTypeSMS,
//	HONChannelInviteButtonTypeEmail,
	HONChannelInviteButtonTypeKakao,
	HONChannelInviteButtonTypeKik,
	HONChannelInviteButtonTypeLine
};

@class HONChannelInviteButtonView;
@protocol HONChannelInviteButtonViewDelegate <NSObject>
@optional
- (void)channelInviteButtonView:(HONChannelInviteButtonView *)buttonView didSelectType:(HONChannelInviteButtonType)buttonType;
@end

@interface HONChannelInviteButtonView : UIView
- (id)initWithFrame:(CGRect)frame asButtonType:(HONChannelInviteButtonType)buttonType;

@property (nonatomic, readonly) HONChannelInviteButtonType buttonType;
@property (nonatomic, assign) id <HONChannelInviteButtonViewDelegate> delegate;;
@end
