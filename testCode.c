#include <stdio.h>
#include <stdlib.h>
#include <ldap.h>

#define BASE_DN "ou=people,dc=wvu,dc=edu"
#define SCOPE LDAP_SCOPE_SUBTREE
#define FILTER "(mail=*cukic*)"

int
Imain() {
  char* host = "ldap://ldap.wvu.edu:389";
  LDAP* ld;
  int ldapErr;
  int version3 = LDAP_VERSION3;

  // Variables pulled from Sun example
  LDAPMessage *res, *msg;
  LDAPControl **serverctrls;
  BerElement *ber;
  char *a, *dn, *matched_msg = NULL, *error_msg = NULL;
  char **vals, **referrals;
  int version, i, rc, parse_rc, msgtype, num_entries = 0, num_refs = 0;

  ldapErr = ldap_initialize(&ld, host);

  if( ldapErr != LDAP_SUCCESS )
    printf("Error initializing LDAP: %s (%d)\n", ldap_err2string(ldapErr), ldapErr);
  else
    printf("Initialization success!\n");

  ldapErr = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &version3);

  if( ldapErr != LDAP_SUCCESS )
    printf("Error setting LDAP version: %s (%d)\n", ldap_err2string(ldapErr), ldapErr);
  else
    printf("Version set success!\n");

  // LDAP Search performed here
  ldapErr = ldap_search_ext_s(ld, BASE_DN, SCOPE, FILTER, NULL, 0,
			      NULL, NULL, NULL, LDAP_NO_LIMIT, &res);

  if( ldapErr != LDAP_SUCCESS ) {
    printf("Error searching LDAP : %s (%d)\n", ldap_err2string(ldapErr), ldapErr);
    return(1);
  } else
    printf("Search successful\n");

  // Loop through search results
  for ( msg = ldap_first_message( ld, res ); msg != NULL; msg = ldap_next_message( ld, msg ) ) {

    /* Determine what type of message was sent from the server. */
    msgtype = ldap_msgtype( msg );
    switch( msgtype ) {

      /* If the result was an entry found by the search, get and print the
	 attributes and values of the entry. */

    case LDAP_RES_SEARCH_ENTRY:

      /* Get and print the DN of the entry. */
      if (( dn = ldap_get_dn( ld, res )) != NULL ) {
	printf( "dn: %s\n", dn );
	ldap_memfree( dn );
      }

      /* Iterate through each attribute in the entry. */
      for ( a = ldap_first_attribute( ld, res, &ber ); a != NULL; a = ldap_next_attribute( ld, res, ber ) ) {

	/* Get and print all values for each attribute. */
	if (( vals = ldap_get_values( ld, res, a )) != NULL ) {

	  for ( i = 0; vals[ i ] != NULL; i++ ) {
	    printf( "Attr: %s: %s\n", a, vals[ i ] );
	  }

	  ldap_value_free( vals );
	}

	ldap_memfree( a );
      }

      if ( ber != NULL ) {
	ber_free( ber, 0 );
      }

      printf( "\n" );
      break;

    case LDAP_RES_SEARCH_REFERENCE:

      /* The server sent a search reference encountered during the
	 search operation. */

      /* Parse the result and print the search references.
	 Ideally, rather than print them out, you would follow the
	 references. */

      parse_rc = ldap_parse_reference( ld, msg, &referrals, NULL, 0 );

      if ( parse_rc != LDAP_SUCCESS ) {
	fprintf( stderr, "ldap_parse_result: %s\n", ldap_err2string( parse_rc ) );
	ldap_unbind( ld );
	return( 1 );
      }

      if ( referrals != NULL ) {
	for ( i = 0; referrals[ i ] != NULL; i++ ) {
	  printf( "Search reference: %s\n\n", referrals[ i ] );
	}

	ldap_value_free( referrals );
      }
      break;

    case LDAP_RES_SEARCH_RESULT:
      /* Parse the final result received from the server. Note the last
	 argument is a non-zero value, which indicates that the
	 LDAPMessage structure will be freed when done. (No need
	 to call ldap_msgfree().) */

      parse_rc = ldap_parse_result( ld, msg, &rc, &matched_msg, &error_msg, NULL, &serverctrls, 0 );
      if ( parse_rc != LDAP_SUCCESS ) {
	fprintf( stderr, "ldap_parse_result: %s\n", ldap_err2string( parse_rc ) );
	ldap_unbind( ld );
	return( 1 );
      }

      /* Check the results of the LDAP search operation. */
      if ( rc != LDAP_SUCCESS ) {
	fprintf( stderr, "ldap_search_ext: %s\n", ldap_err2string( rc ) );
	if ( error_msg != NULL & *error_msg != '\0' ) {
	  fprintf( stderr, "%s\n", error_msg );
	}

	if ( matched_msg != NULL && *matched_msg != '\0' ) {
	  fprintf( stderr, "Part of the DN that matches an existing entry: %s\n", matched_msg );
	}
      } else {

	printf( "Search completed successfully.\n"
	  "Entries found: %d\n"
	  "Search references returned: %d\n",
	  num_entries, num_refs );
      }
      break;

    default:
      break;
    }
  }

  return EXIT_SUCCESS;
}
