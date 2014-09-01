//
//  HONTabBannerView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 08/09/2014 @ 12:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTabBannerView.h"
#import "HONPaginationView.h"

@interface HONTabBannerView ()
@property (nonatomic, strong) NSArray *clubsDict;
@property (nonatomic, strong) HONUserClubVO *areaCodeClubVO;
@property (nonatomic, strong) HONUserClubVO *baeClubVO;
@property (nonatomic, strong) HONUserClubVO *familyClubVO;
@property (nonatomic, strong) HONUserClubVO *schoolClubVO;
@property (nonatomic, strong) HONUserClubVO *workplaceClubVO;
@property (nonatomic, strong) NSMutableArray *clubs;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HONPaginationView *paginationView;
@property (nonatomic) int prevPage;
@property (nonatomic) int currPage;
@property (nonatomic) int totalPages;
@end

@implementation HONTabBannerView
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (kTabSize.height + 64.0), 320.0, 65.0)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBannerBG"]]];
		
		_prevPage = 0;
		_currPage = 0;
		_totalPages = 0;
		
		_clubs = [NSMutableArray array];
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.width)];
		_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
		_scrollView.showsHorizontalScrollIndicator = YES;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];

		[self performSelector:@selector(_delayedPopulate) withObject:nil afterDelay:0.0];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goAreaCode {
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_areaCodeClubVO.clubName considerWhitespace:YES]) {
		if ([self.delegate respondsToSelector:@selector(tabBannerView:joinAreaCodeClub:)])
			[self.delegate tabBannerView:self joinAreaCodeClub:_areaCodeClubVO];
	
	} else
		[self _showAlreadyMemberAlert:_areaCodeClubVO.clubName];
}

- (void)_goFamily {
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_familyClubVO.clubName considerWhitespace:YES]) {
		if ([self.delegate respondsToSelector:@selector(tabBannerView:joinFamilyClub:)])
			[self.delegate tabBannerView:self joinFamilyClub:_familyClubVO];
	
	} else
		[self _showAlreadyMemberAlert:_familyClubVO.clubName];
}

- (void)_goSchool {
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_schoolClubVO.clubName considerWhitespace:YES]) {
		if ([self.delegate respondsToSelector:@selector(tabBannerView:joinSchoolClub:)])
			[self.delegate tabBannerView:self joinSchoolClub:_schoolClubVO];
	
	} else
		[self _showAlreadyMemberAlert:_schoolClubVO.clubName];
}

- (void)_goBae {
	if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:_baeClubVO.clubName considerWhitespace:YES]) {
		if ([self.delegate respondsToSelector:@selector(tabBannerView:createBaeClub:)])
			[self.delegate tabBannerView:self createBaeClub:_baeClubVO];
	
	} else
		[self _showAlreadyMemberAlert:_baeClubVO.clubName];
}

- (void)_goUnlock {
	if ([self.delegate respondsToSelector:@selector(tabBannerViewInviteContacts:)])
		[self.delegate tabBannerViewInviteContacts:self];
}


#pragma mark - UI Presentation
- (void)_delayedPopulate {
	__block int tot = 0;
	[[[HONClubAssistant sharedInstance] suggestedClubs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONUserClubVO *vo = (HONUserClubVO *)obj;
		
		if (vo.clubEnrollmentType == HONClubEnrollmentTypeUnknown)
			return;
		
		if (![[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:vo.clubName]) {
			[_clubs addObject:vo];
			
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * tot, 0.0, 320.0, 65.0)];
			[_scrollView addSubview:imageView];
			
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 17.0, 205.0, 20.0)];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
			titleLabel.textColor = [UIColor blackColor];
			[imageView addSubview:titleLabel];
			
			UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 39.0, 205.0, 14.0)];
			subtitleLabel.backgroundColor = [UIColor clearColor];
			subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
			subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			[imageView addSubview:subtitleLabel];
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = imageView.frame;
			button.backgroundColor = [UIColor clearColor];
			[_scrollView addSubview:button];
			
			if (vo.clubID == -1) {
				_areaCodeClubVO = vo;
				imageView.image = [UIImage imageNamed:@"locationBanner"];
				titleLabel.text = [NSString stringWithFormat:@"Join the %@!", _areaCodeClubVO.clubName];
				subtitleLabel.text = @"Represent your area code.";
				[button addTarget:self action:@selector(_goAreaCode) forControlEvents:UIControlEventTouchUpInside];
				
			} else if (vo.clubID == -2) {
				_familyClubVO = vo;
				imageView.image = [UIImage imageNamed:@"familyBanner"];
				titleLabel.text = [NSString stringWithFormat:@"Create the %@!", _familyClubVO.clubName];
				subtitleLabel.text = @"Stay connected.";
				[button addTarget:self action:@selector(_goFamily) forControlEvents:UIControlEventTouchUpInside];
				
			} else if (vo.clubID == -5) {
				_baeClubVO = vo;
				imageView.image = [UIImage imageNamed:@"baeBanner"];
				titleLabel.text = [NSString stringWithFormat:@"Join the %@!", _baeClubVO.clubName];
				subtitleLabel.text = @"A private club.";
				[button addTarget:self action:@selector(_goBae) forControlEvents:UIControlEventTouchUpInside];
			
			} else if (vo.clubID == -4) {
				_schoolClubVO = vo;
				imageView.image = [UIImage imageNamed:@"schoolBanner"];
				titleLabel.text = [NSString stringWithFormat:@"Join the %@!", _schoolClubVO.clubName];
				subtitleLabel.text = @"Your local school.";
				[button addTarget:self action:@selector(_goSchool) forControlEvents:UIControlEventTouchUpInside];
			}
			
			tot++;
		}
	}];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlockBanner"]];
	imageView.frame = CGRectOffset(imageView.frame, _scrollView.frame.size.width * [_clubs count], 0.0);
	[_scrollView addSubview:imageView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 17.0, 205.0, 20.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.text = @"Over 1M stickers!";
	[imageView addSubview:titleLabel];
	
	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 39.0, 205.0, 14.0)];
	subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
	subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	subtitleLabel.text = @"Invite friends to unlock.";
	[imageView addSubview:subtitleLabel];
	
	UIButton *unlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unlockButton.frame = imageView.frame;
	[unlockButton addTarget:self action:@selector(_goUnlock) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:unlockButton];
	
	_totalPages = [_clubs count] + 1;
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _totalPages, _scrollView.frame.size.height);
	
	_paginationView = [[HONPaginationView alloc] initAtPosition:CGPointMake(160.0, 8.0) withTotalPages:_totalPages usingDiameter:5.0 andPadding:5.0];
	[_paginationView updateToPage:0];
	[self addSubview:_paginationView];
	
//	[[[UIAlertView alloc] initWithTitle:@"Suggested"
//								message:@""
//							   delegate:nil
//					  cancelButtonTitle:@"YES"
//					  otherButtonTitles:nil] show];
}

- (void)_showAlreadyMemberAlert:(NSString *)clubName {
	[[[UIAlertView alloc] initWithTitle:@""
								message:[NSString stringWithFormat:NSLocalizedString(@"alert_member", @"You are already a member of %@!"), clubName]
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
}

#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	int offsetPage = MIN(MAX(round(scrollView.contentOffset.x / scrollView.frame.size.width), 0), _totalPages);
	
	if (offsetPage != _prevPage) {
		[_paginationView updateToPage:offsetPage];
		
		if ([self.delegate respondsToSelector:@selector(tabBannerView:didScrollFromPage:toPage:)])
			[self.delegate tabBannerView:self didScrollFromPage:_prevPage toPage:offsetPage];
		
		_prevPage = offsetPage;
	}
}

@end
