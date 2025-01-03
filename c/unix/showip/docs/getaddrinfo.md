# GETADDRINFO(3) Library Functions Manual

     getaddrinfo, freeaddrinfo – for resolving host and service names to socket address structures."
		                             (socket address structure to host and service name)

## SYNOPSIS
     #include <sys/types.h>
     #include <sys/socket.h>
     #include <netdb.h>

     int getaddrinfo(
			const char *hostname, const char *servname,
	 		const struct addrinfo *hints, struct addrinfo **res);

     void freeaddrinfo(struct addrinfo *ai);

## DESCRIPTION

getaddrinfo() gets a list of IP addresses && port numbers for host `hostname` and service `servname`
It replaces gethostbyname(3) and getservbyname(3).

The hostname and servname arguments are either pointers to NUL-terminated strings or NULL.
An acceptable value for hostname is either a valid host name or a "numeric host address string". 
The numeric host address string is either a dotted decimal IPv4 address or an IPv6 address.  

The servname is either a decimal port number or a service name listed in services(5). 

At least one of hostname and servname must be non-null.

## Hints

hints is an optional pointer to a `struct addrinfo`, as defined by ⟨netdb.h⟩:

struct addrinfo {
	int ai_flags;	       			  /* input flags */
	int ai_family;	       			/* protocol family for socket */
	int ai_socktype;	     			/* socket type */
	int ai_protocol;	     			/* protocol for socket */
	socklen_t ai_addrlen;   		/* length of socket-address */
	struct sockaddr *ai_addr;   /* socket-address for socket */
	char *ai_canonname;     		/* canonical name for service location */
	struct addrinfo *ai_next;   /* pointer to next in list */
};

This structure can be used to provide hints concerning the type of socket that the caller supports or wishes to use.  
The caller can supply the following structure elements in hints:

ai_family	    The protocol family that should be used.  When ai_family
	is set to PF_UNSPEC, it means the caller will accept any
	protocol family supported by the operating system.

ai_socktype    Denotes the type of socket that is wanted: SOCK_STREAM,
	SOCK_DGRAM, or SOCK_RAW.  When ai_socktype is zero the
	caller will accept any socket type.

ai_protocol    Indicates which transport protocol is desired, IPPROTO_UDP
	or IPPROTO_TCP.  If ai_protocol is zero the caller will
	accept any protocol.

ai_flags	    The ai_flags field to which the hints parameter points
	shall be set to zero or be the bitwise-inclusive OR of one
	or more of the values AI_ADDRCONFIG, AI_ALL, AI_CANONNAME,
	AI_NUMERICHOST, AI_NUMERICSERV, AI_PASSIVE, AI_V4MAPPED,
	AI_V4MAPPED_CFG, and AI_DEFAULT.

	AI_ADDRCONFIG   If the AI_ADDRCONFIG bit is set, IPv4
			addresses shall be returned only if an
			IPv4 address is configured on the local
			system, and IPv6 addresses shall be
			returned only if an IPv6 address is
			configured on the local system.

	AI_ALL	    If the AI_ALL bit is set with the
			AI_V4MAPPED bit, then getaddrinfo() shall
			return all matching IPv6 and IPv4
			addresses.	The AI_ALL bit without the
			AI_V4MAPPED bit is ignored.

	AI_CANONNAME    If the AI_CANONNAME bit is set, a
			successful call to getaddrinfo() will
			return a NUL-terminated string containing
			the canonical name of the specified
			hostname in the ai_canonname element of
			the first addrinfo structure returned.

	AI_NUMERICHOST  If the AI_NUMERICHOST bit is set, it
			indicates that hostname should be treated
			as a numeric string defining an IPv4 or
			IPv6 address and no name resolution should
			be attempted.

	AI_NUMERICSERV  If the AI_NUMERICSERV bit is set, then a
			non-null servname string supplied shall be
			a numeric port string.  Otherwise, an
			EAI_NONAME error shall be returned.  This
			bit shall prevent any type of name
			resolution service (for example, NIS+)
			from being invoked.

	AI_PASSIVE	    If the AI_PASSIVE bit is set it indicates
			that the returned socket address structure
			is intended for use in a call to bind(2).
			In this case, if the hostname argument is
			the null pointer, then the IP address
			portion of the socket address structure
			will be set to INADDR_ANY for an IPv4
			address or IN6ADDR_ANY_INIT for an IPv6
			address.

			If the AI_PASSIVE bit is not set, the
			returned socket address structure will be
			ready for use in a call to connect(2) for
			a connection-oriented protocol or
			connect(2), sendto(2), or sendmsg(2) if a
			connectionless protocol was chosen.  The
			IP address portion of the socket address
			structure will be set to the loopback
			address if hostname is the null pointer
			and AI_PASSIVE is not set.

	AI_V4MAPPED     If the AI_V4MAPPED flag is specified along
			with an ai_family of PF_INET6, then
			getaddrinfo() shall return IPv4-mapped
			IPv6 addresses on finding no matching IPv6
			addresses ( ai_addrlen shall be 16).  The
			AI_V4MAPPED flag shall be ignored unless
			ai_family equals PF_INET6.

	AI_V4MAPPED_CFG
			The AI_V4MAPPED_CFG flag behaves exactly
			like the AI_V4MAPPED flag if the kernel
			supports IPv4-mapped IPv6 addresses.
			Otherwise it is ignored.

	AI_DEFAULT	    AI_DEFAULT is defined as ( AI_V4MAPPED_CFG
			| AI_ADDRCONFIG ).

	AI_UNUSABLE     To override the automatic AI_DEFAULT
			behavior that occurs when ai_flags is zero
			pass AI_UNUSABLE instead of zero.  This
			suppresses the implicit setting of
			AI_V4MAPPED_CFG and AI_ADDRCONFIG, thereby
			causing unusable addresses to be included
				in the results.

If ai_flags is zero, getaddrinfo() gives the AI_DEFAULT behavior (
AI_V4MAPPED_CFG | AI_ADDRCONFIG ). To override this default behavior,
pass any nonzero value for ai_flags, by setting any desired flag values,
or setting AI_UNUSABLE if no other flags are desired.

All other elements of the addrinfo structure passed via hints must be
zero or the null pointer.

If hints is the null pointer, getaddrinfo() behaves as if the caller
provided a struct addrinfo with ai_family set to PF_UNSPEC and all other
elements set to zero or NULL (which includes treating the ai_flags field
as effectively zero, giving the automatic default AI_DEFAULT behavior).

After a successful call to getaddrinfo(), *res is a pointer to a linked
list of one or more addrinfo structures.  The list can be traversed by
following the ai_next pointer in each addrinfo structure until a null
pointer is encountered.  The three members ai_family, ai_socktype, and
ai_protocol in each returned addrinfo structure are suitable for a call
to socket(2).  For each addrinfo structure in the list, the ai_addr
member points to a filled-in socket address structure of length
ai_addrlen.

This implementation of getaddrinfo() allows numeric IPv6 address notation
with scope identifier, as documented in section 11 of RFC 4007.  By
appending the percent character and scope identifier to addresses, one
can fill the sin6_scope_id field for addresses.  This would make
management of scoped addresses easier and allows cut-and-paste input of
scoped addresses.

At this moment the code supports only link-local addresses with the
format.  The scope identifier is hardcoded to the name of the hardware
interface associated with the link (such as ne0).	An example is
“fe80::1%ne0”, which means “fe80::1 on the link associated with the ne0
interface”.

The current implementation assumes a one-to-one relationship between the
interface and link, which is not necessarily true from the specification.

All of the information returned by getaddrinfo() is dynamically
allocated: the addrinfo structures themselves as well as the socket
address structures and the canonical host name strings included in the
addrinfo structures.

Memory allocated for the dynamically allocated structures created by a
successful call to getaddrinfo() is released by the freeaddrinfo()
function.	The ai pointer should be an addrinfo structure created by a
call to getaddrinfo().

The current implementation supports synthesis of NAT64 mapped IPv6
addresses.  If hostname is a numeric string defining an IPv4 address (for
example, “192.0.2.1” ) and ai_family is set to PF_UNSPEC or PF_INET6,
getaddrinfo() will synthesize the appropriate IPv6 address(es) (for
example, “64:ff9b::192.0.2.1” ) if the current interface supports IPv6,
NAT64 and DNS64 and does not support IPv4. If the AI_ADDRCONFIG flag is
set, the IPv4 address will be suppressed on those interfaces.  On non-
qualifying interfaces, getaddrinfo() is guaranteed to return immediately
without attempting any resolution, and will return the IPv4 address if
ai_family is PF_UNSPEC or PF_INET. NAT64 address synthesis can be
disabled by setting the AI_NUMERICHOST flag. To best support NAT64
networks, it is recommended to resolve all IP address literals with
ai_family set to PF_UNSPEC and ai_flags set to AI_DEFAULT.

Note that NAT64 address synthesis is always disabled for IPv4 addresses
in the following ranges: 0.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16,
192.0.0.0/29, 192.88.99.0/24, 224.0.0.0/4, and 255.255.255.255/32.
Additionally, NAT64 address synthesis is disabled when the network uses
the well-known prefix (64:ff9b::/96) for IPv4 addresses in the following
ranges: 10.0.0.0/8, 100.64.0.0/10, 172.16.0.0/12, and 192.168.0.0/16.

Historically, passing a host's own hostname to getaddrinfo() has been a
popular technique for determining that host's IP address(es), but this is
fragile, and doesn't work reliably in all cases. The appropriate way for
software to discover the IP address(es) of the host it is running on is
to use getifaddrs(3).

The getaddrinfo() implementations on all versions of OS X and iOS are
now, and always have been, thread-safe. Previous versions of this man
page incorrectly reported that getaddrinfo() was not thread-safe.

RETURN VALUES
     getaddrinfo() returns zero on success or one of the error codes listed in gai_strerror(3) if an error occurs.

EXAMPLES
     The following code tries to connect to “www.kame.net” service “http” via a stream socket.  
		 It loops through all the addresses available, regardless of address family.  
		 If the destination resolves to an IPv4 address, it will use an PF_INET socket. 
		 Similarly, if it resolves to IPv6, an PF_INET6 socket is used.	
		 Observe that there is no hardcoded reference to a particular address family. 
		 The code works even if getaddrinfo() returns addresses that are not IPv4/v6.

```C
	   struct addrinfo hints, *res, *res0;
	   int error;
	   int s;
	   const char *cause = NULL;

	   memset(&hints, 0, sizeof(hints));
	   hints.ai_family = PF_UNSPEC;
	   hints.ai_socktype = SOCK_STREAM;
	   error = getaddrinfo("www.kame.net", "http", &hints, &res0);
	   if (error) {
		   errx(1, "%s", gai_strerror(error));
		   /*NOTREACHED*/
	   }
	   s = -1;
	   for (res = res0; res; res = res->ai_next) {
		   s = socket(res->ai_family, res->ai_socktype,
		       res->ai_protocol);
		   if (s < 0) {
			   cause = "socket";
			   continue;
		   }

		   if (connect(s, res->ai_addr, res->ai_addrlen) < 0) {
			   cause = "connect";
			   close(s);
			   s = -1;
			   continue;
		   }

		   break;  /* okay we got one */
	   }
	   if (s < 0) {
		   err(1, "%s", cause);
		   /*NOTREACHED*/
	   }
	   freeaddrinfo(res0);

     The following example tries to open a wildcard listening socket onto
     service “http”, for all the address families available.

	   struct addrinfo hints, *res, *res0;
	   int error;
	   int s[MAXSOCK];
	   int nsock;
	   const char *cause = NULL;

	   memset(&hints, 0, sizeof(hints));
	   hints.ai_family = PF_UNSPEC;
	   hints.ai_socktype = SOCK_STREAM;
	   hints.ai_flags = AI_PASSIVE;
	   error = getaddrinfo(NULL, "http", &hints, &res0);
	   if (error) {
		   errx(1, "%s", gai_strerror(error));
		   /*NOTREACHED*/
	   }
	   nsock = 0;
	   for (res = res0; res && nsock < MAXSOCK; res = res->ai_next) {
		   s[nsock] = socket(res->ai_family, res->ai_socktype,
		       res->ai_protocol);
		   if (s[nsock] < 0) {
			   cause = "socket";
			   continue;
		   }

		   if (bind(s[nsock], res->ai_addr, res->ai_addrlen) < 0) {
			   cause = "bind";
			   close(s[nsock]);
			   continue;
		   }
		   (void) listen(s[nsock], 5);

		   nsock++;
	   }
	   if (nsock == 0) {
		   err(1, "%s", cause);
		   /*NOTREACHED*/
	   }
	   freeaddrinfo(res0);
```

SEE ALSO
     bind(2), connect(2), send(2), socket(2), gai_strerror(3),
     gethostbyname(3), getnameinfo(3), getservbyname(3), resolver(3),
     hosts(5), resolv.conf(5), services(5), hostname(7), named(8)

STANDARDS
     The getaddrinfo() function is defined by the IEEE Std 1003.1-2004
     (“POSIX.1”) specification and documented in RFC 3493, “Basic Socket
     Interface Extensions for IPv6”.

macOS 15.2			 July 1, 2008			    macOS 15.2
