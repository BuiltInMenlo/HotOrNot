//
//  HONClubAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 05/04/2014 @ 00:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONClubAssistant.h"

@implementation HONClubAssistant
static HONClubAssistant *sharedInstance = nil;

+ (HONClubAssistant *)sharedInstance {
	static HONClubAssistant *s_sharedInstance = nil;
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

- (NSArray *)fpoInviteClubs {
	return (@[@{@"id"				: @"1110001",
				@"name"				: @"Jefferson High",
				@"description"		: @"FPO High School",
				
				@"img"				: @"https://d3j8du2hyvd35p.cloudfront.net/3f3158660d1144a2ba2bb96d8fa79c96_5c7e2f9900fb4d9a930ac11a09b9facb-1389678527Large_640x1136.jpg",
				@"club_type"		: @"SUGGESTED",
				@"added"			: @"2014-03-21 12:43:55",
				
				@"owner"			: @{@"id"			: @"62899",
										@"username"		: @"smileyy_syd",
										@"avatar"		: @"https://d3j8du2hyvd35p.cloudfront.net/efdb098b221b41778409e4d6d3d05f83_b12db29b3dce414899da69ad55effb91-1388538981"},
				
				@"members"			: @[@{@"id"				: @"116900",
										  @"username"		: @"dev_jesse",
										  @"avatar"			: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
										  @"age"			: @"1970-07-08 00:00:00",
										  @"extern_name"	: @"Jesse Boley",
										  @"mobile_number"	: @"",
										  @"email"			: @"jlboley@gmail.com",
										  @"invited"		: @"2014-03-05 10:41:41"}],
				
				@"pending"			: @[@{@"extern_name"	: @"Ken Shabby",
										  @"mobile_number"	: @"+14153456723",
										  @"email"			: @"ken.shabby@gmail.com",
										  @"invited"		: @"2014-03-25 18:31:15"}],
				
				@"blocked"			: @[],
				
				@"submissions"		: @[]
			}]);
}

- (NSArray *)fpoJoinedClubs {
	return (@[@{@"id"				: @"1110002",
				@"name"				: @"Katy Perry",
				
				@"description"		: @"",
				@"img"				: @"https://s3.amazonaws.com/hotornot-challenges/katyPerryLarge_640x1136.jpg",
				@"club_type"		: @"NEARBY",
				@"added"			: @"2014-03-21 12:43:55",
				
				@"owner"			: @{@"id"		: @"10563",
										@"username"	: @"cheylaureenxo",
										@"avatar"	: @"https://d3j8du2hyvd35p.cloudfront.net/8268d1cb4608e0fce19ddc30d1a47a6d247769bc1301f9d1b99c2c5248ce3148-1379717258"},
				
				@"members"			: @[@{@"id"				: @"99629",
										  @"username"		: @"shane5s",
										  @"avatar"			: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
										  @"age"			: @"1997-02-05 16:00:00",
										  @"extern_name"	: @"Shane Hill",
										  @"mobile_number"	: @"+14152549391",
										  @"email"			: @"",
										  @"invited"		: @"2014-03-15 10:21:41"},
										@{@"id"				: @"131796",
										  @"username"		: @"jess4life",
										  @"avatar"			: @"https://d3j8du2hyvd35p.cloudfront.net/e03d3827b9b547db9c2d64fe02389896_fcc05b136a6d4a9dac3767006f555701-1397110912",
										  @"age"			: @"1990-04-10 06:20:36",
										  @"extern_name"	: @"Jessica Rabbit",
										  @"mobile_number"	: @"+13058531028",
										  @"email"			: @"",
										  @"invited"		: @"2014-04-27 03:11:33"}],
				@"pending"			: @[],
				
				@"blocked"			: @[@{@"id"				: @"52802",
										  @"username"		: @"king Afg",
										  @"avatar"			: @"https://d3j8du2hyvd35p.cloudfront.net/2e1716ac9b1046c788a7bb67b0f38705_24f84f0bc545480aab2fe358025c03a2-1388792086",
										  @"age"			: @"1979-12-27 14:54:37",
										  @"extern_name"	: @"Afghan King",
										  @"mobile_number"	: @"",
										  @"email"			: @"",
										  @"invited"		: @"2014-04-27 09:36:19"}],
				
				@"submissions"		: @[]
			}]);
}

- (NSDictionary *)fpoOwnedClubDictionary {
	return (@{@"id"				: @"12",
			  @"name"			: @"Dozen Club",
			  
			  @"description"	: @"",
			  @"img"			: @"https://d3j8du2hyvd35p.cloudfront.net/58027fd1473f4826a669e89ba1d12000_0adcbca42b6541f898f1557fcc4da55a-1388776881",
			  @"club_type"		: @"USER_GENERATED",
			  @"added"			: @"2014-04-28 00:40:03",
			  
			  @"owner"			: @{@"id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
									@"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
									@"avatar"	: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]},
			  
			  @"members"		: @[],
			  @"pending"		: @[],
			  @"blocked"		: @[],
			  
			  @"submissions"	: @[]
			});
}


- (NSDictionary *)emptyClubDictionary {
	return (@{@"id"				: @"",
			  @"name"			: @"",
			  
			  @"description"	: @"",
			  @"img"			: [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"],
			  @"club_type"		: @"",
			  @"added"			: @"0000-00-00 00:00:00",
			  
			  @"owner"			: @{@"id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
									@"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
									@"avatar"	: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]},
			   
			  @"members"		: @[],
			  @"pending"		: @[],
			  @"blocked"		: @[],
			  
			  @"submissions"	: @[]
			});
}

@end
