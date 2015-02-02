//
//  NSRegularExpression+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#define Rx NSRegularExpression
#define RX(pattern) [[NSRegularExpression alloc] initWithPattern:pattern]

@interface RxMatch : NSObject
@property (retain) NSString* value;    /* The substring that matched the expression. */
@property (assign) NSRange   range;    /* The range of the original string that was matched. */
@property (retain) NSArray*  groups;   /* Each object is an RxMatchGroup. */
@property (retain) NSString* original; /* The full original string that was matched against.  */
@end


@interface RxMatchGroup : NSObject
@property (retain) NSString* value;
@property (assign) NSRange range;
@end


@interface NSRegularExpression (BuiltInMenlo)
+ (instancetype)rx:(NSString *)pattern;
+ (instancetype)rx:(NSString *)pattern ignoreCase:(BOOL)ignoreCase;
+ (instancetype)rx:(NSString *)pattern options:(NSRegularExpressionOptions)options;

- (id)initWithPattern:(NSString *)pattern;

- (NSString *)firstMatch:(NSString *)str;
- (RxMatch *)firstMatchWithDetails:(NSString *)str;
- (int)indexOf:(NSString *)str;
- (BOOL)isMatch:(NSString *)matchee;
- (NSArray *)matches:(NSString *)str;
- (NSArray *)matchesWithDetails:(NSString *)str;
- (NSString *)replace:(NSString *)string with:(NSString *)replacement;
- (NSString *)replace:(NSString *)string withBlock:(NSString *(^)(NSString *match))replacer;
- (NSString *)replace:(NSString *)string withDetailsBlock:(NSString *(^)(RxMatch *match))replacer;
- (NSArray *)split:(NSString *)str;
@end
