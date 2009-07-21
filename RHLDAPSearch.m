//
//  RHLDAPSearch.m
//  LDAPTest
//
//  Created by Ricky Hussmann on 7/18/09.
//  Copyright 2009 Ricky Hussmann. All rights reserved.
//

#import "RHLDAPSearch.h"

@implementation RHLDAPSearch

- (id)initWithURL:(NSString *)url andPort:(uint)port
{
	self = [super init];
	if (self) {
	
		// Keeping a copy of this string due to using
		// cStringUsingEncoding. According to the docs,
		//
		// "The returned C string is guaranteed to be
		//	valid only until either the receiver is
		// freed, or until the current autorelease pool
		// is emptied, whichever occurs first."
		//
		// Better safe than sorry...
		//
		_url = [NSString stringWithString:url];
		_initialized = NO;
	}

	return self;
}

- (uint) initializeLDAP: (NSError **) theError  {
	const int version_3 = LDAP_VERSION3;
	int ldap_error;

	ldap_error = ldap_initialize(&_ldap_context, [_url cStringUsingEncoding:NSASCIIStringEncoding]);
	if (ldap_error != LDAP_SUCCESS) {
		NSString *error_string = [NSString stringWithCString:ldap_err2string(ldap_error)];
		NSDictionary *error_dict = [NSDictionary dictionaryWithObject:error_string forKey:@"err_msg"];
		*theError = [[NSError errorWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:error_dict] autorelease];
		return ldap_error;
	}
	
	ldap_error = ldap_set_option(_ldap_context, LDAP_OPT_PROTOCOL_VERSION, &version_3);
	if (ldap_error != LDAP_SUCCESS) {
		NSString *error_string = [NSString stringWithCString:ldap_err2string(ldap_error)];
		NSDictionary *error_dict = [NSDictionary dictionaryWithObject:error_string forKey:@"err_msg"];
		*theError = [[NSError errorWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:error_dict] autorelease];
		return ldap_error;
	}

	return LDAP_SUCCESS;
}

- (int) createLDAPScopeFromRHScope: (RHLDAPSearchScope) scope  {
  int ldap_scope;
  switch (scope) {
		case RH_LDAP_SCOPE_BASE:
			ldap_scope = LDAP_SCOPE_BASE;
			break;
		case RH_LDAP_SCOPE_BASEOBJECT:
			ldap_scope = LDAP_SCOPE_BASEOBJECT;
			break;
		case RH_LDAP_SCOPE_CHILDERN:
			ldap_scope = LDAP_SCOPE_CHILDREN;
			break;
		case RH_LDAP_SCOPE_ONE:
			ldap_scope = LDAP_SCOPE_ONE;
			break;
		case RH_LDAP_SCOPE_ONELEVEL:
			ldap_scope = LDAP_SCOPE_ONELEVEL;
			break;
		case RH_LDAP_SCOPE_SUB:
			ldap_scope = LDAP_SCOPE_SUB;
			break;
		case RH_LDAP_SCOPE_SUBORDINATE:
			ldap_scope = LDAP_SCOPE_SUBORDINATE;
			break;
		case RH_LDAP_SCOPE_SUBTREE:
			ldap_scope = LDAP_SCOPE_SUBTREE;
			break;
		default:
			ldap_scope = LDAP_SCOPE_DEFAULT;
			break;
	}
	
  return ldap_scope;
}

- (NSArray *)searchWithQuery:(NSString *)query withinBase:(NSString *)base usingScope:(RHLDAPSearchScope)scope error:(NSError **)theError
{
	int ldap_error;
	LDAPMessage *res, *msg;
	int ldap_scope;
	
	if (!_initialized) {
		if ( [self initializeLDAP:theError] != LDAP_SUCCESS )
			return nil;
		
		_initialized = YES;
	}

	ldap_scope = [self createLDAPScopeFromRHScope:scope];
	ldap_error = ldap_search_ext_s(_ldap_context, [base cStringUsingEncoding:NSASCIIStringEncoding],
								   ldap_scope, [query cStringUsingEncoding:NSASCIIStringEncoding],
								   NULL, 0, NULL, NULL, NULL, LDAP_NO_LIMIT, &res);

	if (ldap_error != LDAP_SUCCESS) {
		NSString *error_string = [NSString stringWithCString:ldap_err2string(ldap_error)];
		NSDictionary *error_dict = [NSDictionary dictionaryWithObject:error_string forKey:@"err_msg"];
		*theError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:error_dict] autorelease];
		return nil;
	}
}

@end
