//
//  HONSubjectVO.m
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONSubjectVO.h"

@implementation HONSubjectVO
@synthesize subjectID, useType, subjectName, score, addedDate;

+ (HONSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary {
	HONSubjectVO *vo = [[HONSubjectVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.subjectID = [[dictionary objectForKey:@"id"] intValue];
	vo.subjectName = [dictionary objectForKey:@"name"];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	vo.useType = ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"DISABLED"]) ? HONSubjectUseTypeDisabled : ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"COMPOSE"]) ? HONSubjectUseTypeCompose : ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"REPLY"]) ? HONSubjectUseTypeReply : ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"SPECIAL"]) ? HONSubjectUseTypeSpecial : HONSubjectUseTypeUnassigned;
	
	vo.formattedProperties = [NSString stringWithFormat:@".subjectID    : [%d]\n", vo.subjectID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".useType      : [%@]\n", (vo.useType == HONSubjectUseTypeDisabled) ? @"Disabled" : (vo.useType == HONSubjectUseTypeCompose) ? @"Compose" : (vo.useType == HONSubjectUseTypeReply) ? @"Reply" : (vo.useType == HONSubjectUseTypeSpecial) ? @"Special" : (vo.useType == HONSubjectUseTypeUnassigned) ? @"Unassigned" : @"UNKNOWN"];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".subjectName  : [%@]\n", vo.subjectName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score        : [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate    : [%@]\n", vo.addedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".dictionary   : [%@]", vo.dictionary];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
	self.addedDate = nil;
}
@end
