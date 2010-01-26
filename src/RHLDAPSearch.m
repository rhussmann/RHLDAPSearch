//
//  RHLDAPSearch.m
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

#import "RHLDAPSearch.h"

@implementation RHLDAPSearch

- (id)initWithURL:(NSString *)url
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
		_url = [[NSString stringWithString:url] retain];
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

// TODO: Need to create objects in a way in this method such that
// if something in LDAP fails, everything is properly cleaned up.
// That probably relies a lot on using the pre-autoreleased methods
// for generating objects

- (NSArray *)searchWithQuery:(NSString *)query withinBase:(NSString *)base usingScope:(RHLDAPSearchScope)scope error:(NSError **)theError
{
	int ldap_error, ldap_scope, i;
	LDAPMessage *result, *message;
	NSMutableArray *search_results = nil;
	NSMutableDictionary *entry = nil;
	BerElement *binary_data = NULL;
	struct berval bv, *bvals, **bvp = &bvals;
	
	if (!_initialized) {
		if ( [self initializeLDAP:theError] != LDAP_SUCCESS )
			return nil;
		
		_initialized = YES;
	}
	
	ldap_scope = [self createLDAPScopeFromRHScope:scope];
	ldap_error = ldap_search_ext_s(_ldap_context, [base cStringUsingEncoding:NSASCIIStringEncoding],
								   ldap_scope, [query cStringUsingEncoding:NSASCIIStringEncoding],
								   NULL, 0, NULL, NULL, NULL, LDAP_NO_LIMIT, &result);

	if (ldap_error != LDAP_SUCCESS) {
		NSString *error_string = [NSString stringWithCString:ldap_err2string(ldap_error)];
		NSDictionary *error_dict = [NSDictionary dictionaryWithObject:error_string forKey:@"err_msg"];
		*theError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ldap_error userInfo:error_dict] autorelease];
		return nil;
	}
	
	// TODO: Should probably clean this up such that NSMutableArray gets alloc'd
	// with the exact number of entries it needs
	search_results = [[NSMutableArray alloc] initWithCapacity:10];
	
	for ( message = ldap_first_message(_ldap_context, result); message != NULL;
		 message = ldap_next_message(_ldap_context, message) ) {
		
		int mesg_type = ldap_msgtype(message);
		if ( mesg_type != LDAP_RES_SEARCH_ENTRY )
			continue;
		
		ldap_error = ldap_get_dn_ber(_ldap_context, message, &binary_data, &bv);
		
		// TODO: Should probably clean this up such that NSMutableDictionary gets alloc'd
		// with the exact number of entries it needs
		entry = [[NSMutableDictionary alloc] initWithCapacity:10];

		for ( ldap_error = ldap_get_attribute_ber(_ldap_context, message, binary_data, &bv, bvp); ldap_error == LDAP_SUCCESS;
			 ldap_error = ldap_get_attribute_ber(_ldap_context, message, binary_data, &bv, bvp) ) {

			if (bv.bv_val == NULL)
				break;

			// TODO: Should probably clean this up such that NSMutableArray gets alloc'd
			// with the exact number of entries it needs
			NSMutableArray *attributes = [[NSMutableArray alloc] initWithCapacity:10];

			for (i=0; bvals[i].bv_val != NULL; i++) {
				
				// TODO: comment out this NSLog statement in release builds...
				NSLog(@"%s : %s", bv.bv_val, bvals[i].bv_val);
				[attributes addObject:[NSString stringWithCString:bvals[i].bv_val]];
			}

			[entry setObject:[NSArray arrayWithArray:attributes] forKey:[NSString stringWithCString:bv.bv_val]];
			[attributes release];

			if ( bvals )
				ber_memfree( bvals );
		}
		

		if ( binary_data )
			ber_free(binary_data, 0);
		
		[search_results addObject:[NSDictionary dictionaryWithDictionary:entry]];
		[entry release];
	}
	
	ldap_msgfree(result);
	
	NSArray *return_results = [NSArray arrayWithArray:search_results];
	[search_results release];
	return return_results;
}

- (void)dealloc
{
	if ( _initialized ) {
		[_url release];
		
		ldap_unbind_ext(_ldap_context, NULL, NULL);
		_ldap_context = NULL;
		_initialized = NO;
	}
		
	[super dealloc];
}


@end
