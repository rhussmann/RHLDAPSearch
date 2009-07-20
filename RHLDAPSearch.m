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
		*theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:nil];
		return ldap_error;
	}
	
	ldap_error = ldap_set_option(_ldap_context, LDAP_OPT_PROTOCOL_VERSION, &version_3);
	if (ldap_error != LDAP_SUCCESS) {
		*theError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:nil];
		return ldap_error;
	}

	return LDAP_SUCCESS;
}

- (NSArray *)searchWithQuery:(NSString *)query error:(NSError **)theError
{
	if (!_initialized) {
		if ( [self initializeLDAP:theError] != LDAP_SUCCESS )
			return nil;
		
		_initialized = YES;
	}

	
	return nil;
}

@end
