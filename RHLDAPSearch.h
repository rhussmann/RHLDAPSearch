//
//  RHLDAPSearch.h
//  LDAPTest
//
//  Created by Ricky Hussmann on 7/18/09.
//  Copyright 2009 Ricky Hussmann. All rights reserved.
//

// This code was built against OpenLDAP 2.4.16.
// For support of iPhone OS 3.0, the library should
// be configured in the following manner:
//
// ./configure --without-kerberos --without-tls --disable-kpasswd --without-cyrus-sasl --disable-slapd --disable-backends --disable-overlays --without-gssapi
// 
// Configuring as above will leave out support for
// libraries the iPhone does not natively provide, nor
// needed for talking to WVUs LDAP service.

// TODO: Determine if there is a way to query an LDAP
// context for it's associated URL and port...

// TODO: Clean up memory leaks for failed and
// successful searches

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

- (id)initWithURL:(NSString *)url;
- (NSArray *)searchWithQuery:(NSString *)query withinBase:(NSString *)base usingScope:(RHLDAPSearchScope)scope error:(NSError **)theError;

@end
