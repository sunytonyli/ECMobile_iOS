//
//	 ______    ______    ______
//	/\  __ \  /\  ___\  /\  ___\
//	\ \  __<  \ \  __\_ \ \  __\_
//	 \ \_____\ \ \_____\ \ \_____\
//	  \/_____/  \/_____/  \/_____/
//
//
//	Copyright (c) 2014-2015, Geek Zoo Studio
//	http://www.bee-framework.com
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the "Software"),
//	to deal in the Software without restriction, including without limitation
//	the rights to use, copy, modify, merge, publish, distribute, sublicense,
//	and/or sell copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//	IN THE SOFTWARE.
//

#import "Bee_HTTPClientConfig.h"
#import "Bee_HTTPRequestQueue.h"
#import "Bee_Reachability.h"

#import "NSObject+BeeNotification.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

DEF_PACKAGE( BeeHTTPClient, BeeHTTPClientConfig, config );

#pragma mark -

#undef	CONCURRENT_FOR_WIFI
#define	CONCURRENT_FOR_WIFI	(10)

#undef	CONCURRENT_FOR_WLAN
#define	CONCURRENT_FOR_WLAN	(5)

#pragma mark -

@interface BeeHTTPClientConfig()
{
	NSUInteger	_concurrentForWIFI;
	NSUInteger	_concurrentForWLAN;
	NSString *	_userAgent;
}

- (void)switchWIFI;
- (void)switchWLAN;

@end

#pragma mark -

@implementation BeeHTTPClientConfig

DEF_SINGLETON( BeeHTTPClientConfig )

@synthesize concurrentForWIFI = _concurrentForWIFI;
@synthesize concurrentForWLAN = _concurrentForWLAN;
@synthesize userAgent = _userAgent;

+ (BOOL)autoLoad
{
	[BeeHTTPClientConfig sharedInstance];
	return YES;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.concurrentForWIFI = CONCURRENT_FOR_WIFI;
		self.concurrentForWLAN = CONCURRENT_FOR_WIFI;
		self.userAgent = [NSString stringWithFormat:@"bee/%@", BEE_VERSION];

		[self switchWIFI];

		[self observeNotification:BeeReachability.CHANGED];
		[self observeNotification:BeeReachability.WIFI_REACHABLE];
		[self observeNotification:BeeReachability.WLAN_REACHABLE];
		[self observeNotification:BeeReachability.UNREACHABLE];
	}
	return self;
}

- (void)dealloc
{
	[self unobserveAllNotifications];
	
	[super dealloc];
}

- (void)switchWIFI
{
	[[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:CONCURRENT_FOR_WIFI];
}

- (void)switchWLAN
{
	[[ASIHTTPRequest sharedQueue] setMaxConcurrentOperationCount:CONCURRENT_FOR_WLAN];
}

ON_NOTIFICATION( notification )
{
	if ( [notification is:BeeReachability.WIFI_REACHABLE] )
	{
		[self switchWIFI];
	}
	else if ( [notification is:BeeReachability.WLAN_REACHABLE] )
	{
		[self switchWLAN];
	}
	else if ( [notification is:BeeReachability.UNREACHABLE] )
	{
		
	}
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__

TEST_CASE( BeeHTTPClientConfig )
{
}
TEST_CASE_END

#endif	// #if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__
