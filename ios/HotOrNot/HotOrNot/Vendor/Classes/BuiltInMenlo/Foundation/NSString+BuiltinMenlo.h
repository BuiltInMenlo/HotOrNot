
@interface NSString (BuiltInMenlo)
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

- (BOOL)isValidEmailAddress;
- (NSString *)lastComponentByDelimeter:(NSString *)delimiter;
- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring;
- (void)trimFinalSubstring:(NSString *)substring;
- (NSString *)normalizedPhoneNumber;
- (NSDictionary *)parseAsQueryString;
- (BOOL)isDelimitedByString:(NSString *)delimiter;
- (NSString *)stringFromAPNSToken:(NSData *)remoteToken;
@end
