//
//  UIImage+Base64URI.m
//  Pods
//
//  Created by Anthony Wong on 2014-08-06.
//
//

#define COMPRESS

#import "UIImage+Base64URI.h"

@implementation UIImage (Base64URI)

- (NSString *)base64URI
{
    // Convert to base64
#ifdef COMPRESS
    NSData *data = UIImageJPEGRepresentation(self, 0.6);
#else
    NSData *data = UIImagePNGRepresentation(self);
#endif
    
    if (!data) {
        return nil;
    }
    
    // We use the deprecated base64Encoding method here because we support iOS6+.
    // Pragmas to silence warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *base64 = [data base64Encoding];
#pragma clang diagnostic pop

#ifdef COMPRESS
    NSString *dataURI = [NSString stringWithFormat:@"data:image/jpg;base64,%@", base64];
#else
    NSString *dataURI = [NSString stringWithFormat:@"data:image/png;base64,%@", base64];

#endif
    return dataURI;
}
@end
