<cfinclude template="layout/header.cfm" />
<h3>Example of Using the DynamicXMLBeanFactory</h3>

<p>We will replace dynamic values in the ColdSpring XML configuration and then create the bean factory. 
The code to do this might look like:</p>

<p style="font-family:monospace;">
&lt;!--- <br />
Define the values for the dynamic properties. <br />
These will be used to perform the replacement in the XML. <br />
---&gt;<br />
&lt;cfset var dynamicProperties = StructNew() /&gt;<br />
&lt;cfset dynamicProperties.beanUtilsPackage = "beanutils" /&gt;<br />
&lt;cfset dynamicProperties.examplePackage = "beanutils.example" /&gt;<br />
&lt;cfset dynamicProperties.lazyInitRemoteProxies = "false" /&gt;<br />
&lt;cfset dynamicProperties.applicationPath = "/beanutils/example/" /&gt;<br />
<br />
&lt;!--- <br />
Load the ColdSpring Dynamic XML Bean Factory, which will replace any dynamic values in the XML with matching properties I specified.<br />
---&gt;<br />
&lt;cfset application.beanFactory = <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CreateObject('component', 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'&#35;dynamicProperties.beanUtilsPackage&#35;.DynamicXmlBeanFactory').init() /&gt;<br />
&lt;cfset application.beanFactory.loadBeansFromDynamicXmlFile('coldspring.xml', dynamicProperties) /&gt;<br />
</p>
 
<p>
This runs in the Application.cfc onRequestStart() method.<br />
The dynamic properties in the <a href="coldspring.xml" target="_blank">coldspring.xml</a> file are specified using the syntax ${propertyName}.
</p>


<p>Finally, test that ColdSpring works by using getBean('userService'):</p>
<div style="padding-left:50px;">
<cfdump var="#application.beanFactory.getBean('userService')#" label="User Service">
</div>
<p/>
<p>You may which to look at the <a href="http://environmentconfig.riaforge.org/" target="_blank">Environment Config RIAForge Project</a>
to see a more robust way to specify the dynamic property values that are passed to the DynamicXMLBeanFactory. The Environment CFC uses XML to define properties, and supports different
sets of properties based on host name or a custom identifier (i.e. dev, stage, or production).</p>


<cfinclude template="layout/footer.cfm" />