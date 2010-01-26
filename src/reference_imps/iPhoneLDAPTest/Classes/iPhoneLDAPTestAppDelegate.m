//
//  iPhoneLDAPTestAppDelegate.m
//  iPhoneLDAPTest
//
//  Created by Ricky Hussmann on 7/29/09.
//  Copyright Ricky Hussmann 2009. All rights reserved.
//

#import "iPhoneLDAPTestAppDelegate.h"
#import "RHLDAPSearch.h"

@implementation iPhoneLDAPTestAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

-(IBAction)searchAgain:(id)sender {
	NSArray* search_result;
	NSError* searchError;
	NSLog(@"Hello!");
	
	RHLDAPSearch *mySearch = [[RHLDAPSearch alloc] initWithURL:@"ldap://localhost:3389"];
	search_result = [mySearch searchWithQuery:@"(mail=*cukic*)" withinBase:@"ou=people,dc=wvu,dc=edu" usingScope:RH_LDAP_SCOPE_SUBTREE error:&searchError];
	
	if ( search_result == nil ) {
		NSLog(@"Search error: %@", [[searchError userInfo] valueForKey:@"err_msg"]);
	}
	
	[mySearch release];
}

@end
