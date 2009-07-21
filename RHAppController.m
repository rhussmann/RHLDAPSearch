//
//  RHAppController.m
//  LDAPTest
//
//  Created by Ricky Hussmann on 7/13/09.
//  Copyright 2009 Ricky Hussmann. All rights reserved.
//

#import "RHAppController.h"
#import "RHLDAPSearch.h"

@implementation RHAppController

-(IBAction) doSomeSearch:(id)sender
{
	NSArray* search_result;
	NSError* searchError;
	NSLog(@"Hello!");
	
	RHLDAPSearch *mySearch = [[RHLDAPSearch alloc] initWithURL:@"ldap://localhost:3389" andPort:389];
	search_result = [mySearch searchWithQuery:@"(mail=cukic)" withinBase:@"ou=people,dc=wvu,dc=edu" usingScope:RH_LDAP_SCOPE_SUBTREE error:&searchError];
	
	if ( search_result == nil ) {
		NSLog(@"Search error: %@", [[searchError userInfo] valueForKey:@"err_msg"]);
	}
}

@end
