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
	
	vo.useType = HONSubjectUseTypeUnassigned;
	vo.useType += (int)(([[[dictionary objectForKey:@"type"] uppercaseString] containsString:@"DISABLED"]) * HONSubjectUseTypeDisabled);
	vo.useType += (int)(([[[dictionary objectForKey:@"type"] uppercaseString] containsString:@"COMPOSE"]) * HONSubjectUseTypeCompose);
	vo.useType += (int)(([[[dictionary objectForKey:@"type"] uppercaseString] containsString:@"REPLY"]) * HONSubjectUseTypeReply);
	vo.useType += (int)(([[[dictionary objectForKey:@"type"] uppercaseString] containsString:@"SPECIAL"]) * HONSubjectUseTypeSpecial);
	
	NSMutableArray *useTypes = [NSMutableArray array];
	if (vo.useType & HONSubjectUseTypeDisabled)
		[useTypes addObject:@"Disabled"];
	
	if (vo.useType & HONSubjectUseTypeCompose)
		[useTypes addObject:@"Compose"];
	
	if (vo.useType & HONSubjectUseTypeReply)
		[useTypes addObject:@"Reply"];
	
	if (vo.useType & HONSubjectUseTypeSpecial)
		[useTypes addObject:@"Special"];
	
	vo.formattedProperties = [NSString stringWithFormat:@".subjectID    : [%d]\n", vo.subjectID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".useType      : [%@]\n", [useTypes componentsJoinedByString:@"|"]];
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
