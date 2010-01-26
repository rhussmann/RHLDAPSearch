RHLDAPSearch - An Objective-C Wrapper for OpenLDAP
==================================================

* Created by [Ricky Hussmann](http://www.rhussmann.com)

What is RHLDAPSearch
====================

RHLDAPSearch is a very simple Objective-C based wrapper around the open-source LDAP implementation [OpenLDAP](http://www.openldap.org/)

RHLDAPSearch was created to facilitate an LDAP query interface for the application [iWVU](http://jaredcrawford.org/iWVU/iWVU.html), although this functionality has been replaced. The code provides to important pieces of functionality:

* `fat_build.sh` - a script to help configure and build OpenLDAP for use in both the iPhone simulator and on the iPhone hardware
* `RHLDAPSearch.[h|m]` - a simple wrapper around the OpenLDAP C-based query calls. The `query` that is passed to [RHLDAPSearch searchWithQuery: withinBase: usingScope:] must be a properly formatted LDAP search query.

License
=======
RHLDAPSearch is licensed under the MIT license.