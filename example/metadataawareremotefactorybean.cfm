<cfinclude template="layout/header.cfm" />
<h3>Example of Using the MetadataAwareRemoteFactoryBean</h3>

<p>ColdSpring has generated a Remote Proxy component for our UserService.<br />
We are about to invoke that Remote Proxy as a web service by using the URL:</p>
<p><strong>http://localhost:8500/beanutils/example/RemoteUserService.cfc?wsdl</strong></p>
<p>and call the getUser() remote method.</p>

<p>
Normally, calling getUser() on our RemoteUserService would return a User object, because
that is what the underlying UserService returns from its getUser() method.
What we have done is apply an AOP advice to the RemoteUserService's getUser() method that will convert
the User object into a typed structure that could be used by a Flex application.
Flex sees the typed structure as a real User object. Using this workaround, it is
possible to send large numbers of objects to Flex (perhaps from a query) without
incurring the overhead of creating a large number of CFC instances.
</p>

<cfinvoke webservice="http://localhost:8500/beanutils/example/RemoteUserService.cfc?wsdl" 
	method="getUser" 
	returnvariable="remoteResult">
</cfinvoke>

<div style="padding-left:50px;">
<cfdump var="#remoteResult#" label="Response from Web Service">
</div>
<p/>
<p>The web service call to RemoteUserService triggered the following sequence of events:</p>
<ol>
	<li>RemoteUserService recieves the method call and hands processing to the first (and only) interceptor <a href="../VOConverterAdvice.cfc" target="_blank">VOConverterAdvice</a></li>
	<li>The VOConverterAdvice proceeds with the method call to <a href="UserService.cfc" target="_blank">UserService</a>'s getUser()</li>
	<li>UserService.getUser() returns a User object to the Advice</li>
	<li>Because VOConverterAdvice extends <a href="../AbstractMetadataAwareAdvice.cfc" target="_blank">AbstractMetadataAwareAdvice</a>, it locates the metadata<br />
	configuration file named "userservice.xml" at the location specified by the advice's "metadataPath"<br />
	property (see the <a href="coldspring.xml" target="_blank">coldspring.xml</a>)</li>
	<li>The advice parses the XML and locates metadata specified for the getUser() method<br />
	(see the <a href="userservice.xml" target="_blank">userservice.xml</a>)</li>
	<li>The metadata specifies that a ColdSpring bean named "UserVOConverter" should be used to<br />
	perform the conversion</li>
	<li>The VOConverterAdvice passes the metadata and the user object to the <a href="UserVOConverter.cfc" target="_blank">UserVOConverter</a></li>
	<li>UserVOConverter uses the metadata and the object to generate a typed structure containing the User data</li>
	<li>The typed structure is returned to the VOConverterAdvice</li>
	<li>The typed structure is returned to the RemoteUserService</li>
	<li>The RemoteUserService returns the typed structure to the caller (in this case, the web service call)</li>
</ol>

<p>
Normally, it would not be possible to dynamically configure the VOConverterAdvice to use different
converter objects for different method calls. An entirely separate Advice would have to be configured
in the coldspring.xml. By adding metadata, the Advice becomes far more flexible and is able to use
the proper converters that may be required by different method calls. Other possible uses include specifying
what variables to log for different method calls in a LoggingAdvice, or specifying security rules for different
method calls in a SecurityAdvice.
</p>

<cfinclude template="layout/footer.cfm" />