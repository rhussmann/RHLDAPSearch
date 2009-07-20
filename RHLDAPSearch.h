//
//  RHLDAPSearch.h
//  LDAPTest
//
//  Created by Ricky Hussmann on 7/18/09.
//  Copyright 2009 Ricky Hussmann. All rights reserved.
//

// TODO: Determine if there is a way to query an LDAP
// context for it's associated URL and port...

// TODO: Autorelease the created NSError objects

// TODO: Add LDAP error text to NSError dictionaries

#import "ldap.h"

@interface RHLDAPSearch : NSObject {
	LDAP *_ldap_context;
	NSString *_url;
	bool _initialized;
}

- (id)initWithURL:(NSString *)url andPort:(uint)port;
- (NSArray *)searchWithQuery:(NSString *)query error:(NSError **)theError;

@end
