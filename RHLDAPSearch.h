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

typedef enum RHSearchScope { 
RH_LDAP_SCOPE_BASE, RH_LDAP_SCOPE_BASEOBJECT,
RH_LDAP_SCOPE_ONELEVEL, RH_LDAP_SCOPE_ONE,
RH_LDAP_SCOPE_SUBTREE, RH_LDAP_SCOPE_SUB,
RH_LDAP_SCOPE_SUBORDINATE, RH_LDAP_SCOPE_CHILDERN,
RH_LDAP_SCOPE_DEFAULT
} RHLDAPSearchScope;

@interface RHLDAPSearch : NSObject {
	LDAP *_ldap_context;
	NSString *_url;
	bool _initialized;
}

- (id)initWithURL:(NSString *)url andPort:(uint)port;
- (NSArray *)searchWithQuery:(NSString *)query withinBase:(NSString *)base usingScope:(RHLDAPSearchScope)scope error:(NSError **)theError;

@end
