//
//  RHLDAPSearch.h
//
//  Created by Ricky Hussmann on 7/18/09.
//  Copyright (c) 2009 Ricky Hussmann
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
