<cfinclude template="layout/header.cfm" />
<h3>Example of Using the BeanInjector</h3>

<p>ColdSpring is excellent for managing dependencies for Singleton objects. However, because of the
overhead required for dependency resolution, ColdSpring may not be optimal for "transient" objects,
meaning objects that only exist for one request. There are also situations where other factories,
such as Transfer or Reactor, actually create objects for you. These cannot be managed by ColdSpring
even if one was willing to accept the overhead of using ColdSpring for transient objects.</p>

<p>The BeanInjector component can help here. It will look at the setters for an object and attempt
to locate any ColdSpring beans with the same name. If it finds one, it will inject that bean into
the transient and cache that dependency. Which means that after the first autowire() is handled, all
subsequent autowire() calls for that object type are pulled from the BeanInjector cache. This makes
autowiring objects very fast.</p>

<p>In this example, our User object (a transient) has a setUserService() method in it. When my
UserFactory creates a User it will autowire it using the BeanInjector. That means that my User can
make calls to the UserService as part of its behavior. This allows the User object to perform much
more robust and complex logic than it otherwise could.</p>

<p>To show it working, I will get a User and call getUserService() on it. This is just a simple
example, but any number of ColdSpring beans can be injected into transients using the BeanInjector.</p>

<div style="padding-left:50px;">
<cfset user = application.beanFactory.getBean('userService').getUser() />	
<cfdump var="#user.getUserService()#" />
</div>

<p/>
<p>This ability to inject dependencies into Transient objects opens up a huge range of possibilities.
If you have a ValidatorFactory managed by ColdSpring, you can inject that into your transient objects
so that they can obtain the correct Validator object and validate themselves. Perhaps you want to be
able to ask a User object if it has permission to do something. You could inject a SecurityService into
the User and give it the ability to do that. Or inject an InvoiceService into the User and you can call
user.hasOutstandingInvoices(). You can see how much more powerful this allows us to make our business
objects whether we create them ourselves, or get them from Transfer or Reactor.</p>

<cfinclude template="layout/footer.cfm" />