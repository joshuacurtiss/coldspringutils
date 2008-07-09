<cfinclude template="layout/header.cfm" />
<h3>Example of Using the MetadataAwareProxyFactoryBean</h3>

<p>This works almost exactly the same way that the MetadataAwareRemoteFactoryBean does, except that
it doesn't generate a remote CFC, but instead generates a component in ColdSpring's bean cache which
proxies the underlying object and can have AOP advices applied to it.</p>

<p>Just for a test case, I applied the same VOConverterAdvice to the AOP proxy. To test it, I don't have
to use a web service as I did with the remote proxy. I will just call getBean('proxiedUserService') and
then call getUser(). If the advice is working properly, the result will be the converted User structure instead
of a User object:</p>
<div style="padding-left:50px;">
<cfdump var="#application.beanFactory.getBean('proxiedUserService').getUser()#" label="Response from Proxy">
</div>
<p/>
<p>This has the same possibilities as the MetadataAwareRemoteFactoryBean, for all the same reasons: your Advices
can now act in a much more intelligent way and can change their behavior dynamically based on information
supplied in the metadata configuration file.</p>

<cfinclude template="layout/footer.cfm" />