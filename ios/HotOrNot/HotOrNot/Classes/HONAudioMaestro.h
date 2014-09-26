//
//  HONAudioMaestro.h
//  HotOrNot
//
//  Created by BIM  on 9/25/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONAudioMaestro : NSObject
+ (HONAudioMaestro *)sharedInstance;

- (void)cafPlaybackWithFilename:(NSString *)filename;

@end
