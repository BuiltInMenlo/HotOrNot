//
//  HONAudioMaestro.m
//  HotOrNot
//
//  Created by BIM  on 9/25/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "HONAudioMaestro.h"

@implementation HONAudioMaestro
static HONClubAssistant *sharedInstance = nil;

+ (HONAudioMaestro *)sharedInstance {
	static HONAudioMaestro *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}



- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (void)cafPlaybackWithFilename:(NSString *)filename {
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"caf"]];
	SystemSoundID sound;
	
	AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url, &sound);
	AudioServicesPlaySystemSound(sound);
}

@end
