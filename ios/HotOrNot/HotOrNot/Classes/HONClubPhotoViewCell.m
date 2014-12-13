//
//  HONClubPhotoViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+AdditionalSets.h"
#import "NSDate+Operations.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "PicoSticker.h"

#import "HONClubPhotoViewCell.h"
#import "HONImageLoadingView.h"
#import "HONCommentViewCell.h"

@interface HONClubPhotoViewCell () <HONCommentViewCellDelegate>
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) UIImageView *inputBGImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *replies;

@end

@implementation HONClubPhotoViewCell
@synthesize clubVO = _clubVO;
@synthesize clubPhotoVO = _clubPhotoVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	
	[self hideChevron];
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self.contentView asLargeLoader:NO];
	[self.contentView addSubview:_imageLoadingView];
	
	_imgView = [[UIImageView alloc] initWithFrame:self.frame];
	[self.contentView addSubview:_imgView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_imgView.image = image;
		[_imageLoadingView stopAnimating];
		[_imageLoadingView removeFromSuperview];
		_imageLoadingView = nil;
		
		[_imgView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieGradientOverlay"]]];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[_imgView setImageWithURL:[NSURL URLWithString:[[[HONClubAssistant sharedInstance] defaultClubPhotoURL] stringByAppendingString:kSnapLargeSuffix]]];
		[_imageLoadingView stopAnimating];
		[_imageLoadingView removeFromSuperview];
		_imageLoadingView = nil;
	};
	
	NSString *url = [_clubPhotoVO.imagePrefix stringByAppendingString:kSnapLargeSuffix];
//	NSLog(@"URL:[%@]", url);
	[_imgView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]
													  cachePolicy:kOrthodoxURLCachePolicy
												  timeoutInterval:[HONAppDelegate timeoutInterval]]
					placeholderImage:nil
							 success:imageSuccessBlock
							 failure:imageFailureBlock];
	
	
//	NSLog(@"FRAME:[%@][%@]", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.contentView.frame));
		
	
	
	NSLog(@"SUBJECT:[%d]", [[_clubPhotoVO.dictionary objectForKey:@"text"] length]);
	if ([[_clubPhotoVO.dictionary objectForKey:@"text"] length] > 0) {
		UIView *subjectBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 262.0, 320.0, 44.0)];
		subjectBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[self.contentView addSubview:subjectBGView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 7.0, 280.0, 24.0)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		subjectLabel.text = [_clubPhotoVO.dictionary objectForKey:@"text"];
		[subjectBGView addSubview:subjectLabel];
	}
	
	UIButton *cancelReplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelReplyButton.frame = self.frame;
	[cancelReplyButton addTarget:self action:@selector(_goCancelReply) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:cancelReplyButton];
	
	_replies = [[HONClubAssistant sharedInstance] repliesForClubPhoto:_clubPhotoVO];
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 88.0, 320.0, 44.0)];
	_footerView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_footerView];
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_footerView addSubview:commentButton];
	
	if ([_replies count] > 0)
		[commentButton addTarget:self action:@selector(_goToggleComments) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 12.0, 280.0, 20.0)];
	repliesLabel.backgroundColor = [UIColor clearColor];
	repliesLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	repliesLabel.text = NSStringFromInt([_replies count]);
	[_footerView addSubview:repliesLabel];
	
	_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_upVoteButton.frame = CGRectMake(157.0, 0.0, 44.0, 44.0);
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Disabled"] forState:UIControlStateDisabled];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateNormal];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
	[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForClubPhoto:_clubPhotoVO])];
	[_footerView addSubview:_upVoteButton];
	
	_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_downVoteButton.frame = CGRectMake(274.0, 0.0, 44.0, 44.0);
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Disabled"] forState:UIControlStateDisabled];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateNormal];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
	[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForClubPhoto:_clubPhotoVO])];
	[_footerView addSubview:_downVoteButton];
	
	NSLog(@"HAS VOTED:[%@]", NSStringFromBOOL([[HONClubAssistant sharedInstance] hasVotedForClubPhoto:_clubPhotoVO]));
	if (![[HONClubAssistant sharedInstance] hasVotedForClubPhoto:_clubPhotoVO]) {
		[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
		[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	}
	
	_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(198.0, 12.0, 80.0, 20.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	_scoreLabel.text = @"…";
	[_footerView addSubview:_scoreLabel];
	
	[[HONAPICaller sharedInstance] retrieveVoteTotalForChallengeWithChallengeID:_clubPhotoVO.challengeID completion:^(NSString *result) {
		_clubPhotoVO.score = [result intValue];
		_scoreLabel.text = NSStringFromInt(_clubPhotoVO.score);
	}];
	
	
	_inputBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	_inputBGImageView.frame = CGRectOffset(_inputBGImageView.frame, 0.0, self.frame.size.height - 44.0);
	_inputBGImageView.userInteractionEnabled = YES;
	[self.contentView addSubview:_inputBGImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 12.0, 280.0, 22.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeyDone];
	[_commentTextField setTextColor:[UIColor blackColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_commentTextField.keyboardType = UIKeyboardTypeAlphabet;
	_commentTextField.placeholder = NSLocalizedString(@"enter_comment", @"Comment");
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_inputBGImageView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(265.0, 0.0, 50.0, 44.0);
	_submitCommentButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateDisabled];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateNormal];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateHighlighted];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goSubmitComment) forControlEvents:UIControlEventTouchUpInside];
	[_submitCommentButton setEnabled:NO];
	[_inputBGImageView addSubview:_submitCommentButton];
}


#pragma mark - Navigation
- (void)_goCancelReply {
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
}

- (void)_goCollapseComments {
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _footerView.frame = CGRectTranslateY(_footerView.frame, self.frame.size.height - 88.0);
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_goToggleComments {
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _footerView.frame = (_footerView.frame.origin.y == self.frame.size.height - 88.0) ? CGRectTranslateY(_footerView.frame, (self.frame.size.height * 0.5) - 44.0) : CGRectTranslateY(_footerView.frame, self.frame.size.height - 88.0);
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_goSubmitComment {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:replyToPhoto:withComment:)])
		[self.delegate clubPhotoViewCell:self replyToPhoto:_clubPhotoVO withComment:_commentTextField.text];
}

- (void)_goDownVote {
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	_scoreLabel.text = NSStringFromInt(_clubPhotoVO.score - 1);
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:downVotePhoto:)])
		[self.delegate clubPhotoViewCell:self downVotePhoto:_clubPhotoVO];
}

- (void)_goUpVote {
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	_scoreLabel.text = NSStringFromInt(_clubPhotoVO.score + 1);
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:upVotePhoto:)])
		[self.delegate clubPhotoViewCell:self upVotePhoto:_clubPhotoVO];
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_commentTextField.text isEqualToString:@"¡"]) {
		_commentTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
	
	[_submitCommentButton setEnabled:([_commentTextField.text length] > 0)];
}


#pragma mark - UI Presentation


#pragma mark - CommentViewCell Delegates
- (void)commentViewCell:(HONCommentViewCell *)cell didDownVoteComment:(HONCommentVO *)commentVO {
	
}
	
- (void)commentViewCell:(HONCommentViewCell *)cell didUpVoteComment:(HONCommentVO *)commentVO {
	
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_replies count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCommentViewCell alloc] init];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	cell.delegate = self;
		
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (60.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	[self _goCollapseComments];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.frame.size.height - (216.0 + _inputBGImageView.frame.size.height));
					 } completion:^(BOOL finished) {}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 80 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.frame.size.height - 44.0);
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEndOnExit:[%@]", _commentTextField.text);
}

@end
