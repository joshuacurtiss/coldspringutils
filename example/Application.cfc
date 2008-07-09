<cfcomponent name="Application">

	<cfscript>
	this.name = '#Hash(GetBaseTemplatePath())#';
	this.applicationTimeout = CreateTimeSpan( 0, 0, 10, 0 );
	this.clientManagement = false;
	this.clientStorage = '';
	this.loginStorage = 'session';
	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan( 0, 0, 5, 0 );
	this.setClientCookies = true;
	this.setDomainCookies = true;
	this.scriptProtect = true;
	</cfscript>

	<cffunction name="onApplicationStart" hint="" access="public" returntype="boolean">
		<!--- 
		<cffile output="#now()#: onApplicationStart" action="write" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />
		--->
		<cfreturn true />
	</cffunction>
	
	<cffunction name="onSessionStart" hint="" access="public" returntype="void">
		<!--- 
		<cffile output="#now()#: onSessionStart" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />
		--->
	</cffunction>

	<cffunction name="onRequestStart" hint="" access="public" returntype="boolean">
		<cfargument name="theTargetPage" type="String" required="true"/>
		<cfset var dynamicProperties = StructNew() />
		<cfset dynamicProperties.beanUtilsPackage = "beanutils" />
		<cfset dynamicProperties.examplePackage = "#dynamicProperties.beanUtilsPackage#.example" />
		<cfset dynamicProperties.lazyInitRemoteProxies = "false" />
		<cfset dynamicProperties.applicationPath = "/beanutils/example/" />
		
		<!--- Load the ColdSpring Dynamic XML Bean Factory, which will replace any dynamic values 
			  in the XML with matching properties I specified. --->
		<cfset application.beanFactory = CreateObject('component', '#dynamicProperties.beanUtilsPackage#.DynamicXmlBeanFactory').init() />
		<cfset application.beanFactory.loadBeansFromDynamicXmlFile('coldspring.xml', dynamicProperties) />
		
		
		<!--- 
		<cffile output="#now()#: onRequestStart for #arguments.theTargetPage#" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />
		--->
		<cfreturn true />
	</cffunction>
	<!--- 
	<cffunction name="onRequest" hint="" access="public" returntype="void">
		<cfargument name="theTargetPage" type="String" required="true"/>
		<cffile output="#now()#: onRequest for #arguments.theTargetPage#" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />
		<cfinclude template="#arguments.theTargetPage#">
	</cffunction>
	 --->
	<cffunction name="onRequestEnd" hint="" access="public" returntype="void">
		<cfargument name="theTargetPage" type="String" required="true"/>
		<!--- 
		<cffile output="#now()#: onRequestEnd for #arguments.theTargetPage#" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />	
		--->
	</cffunction>	
	
	<cffunction name="onSessionEnd" hint="" access="public" returntype="void">
		<cfargument name="sessionScope" required="true" />
		<cfargument name="applicationScope" required="false" />
		<!---
		<cffile output="#now()#: onSessionEnd (#structKeyList( arguments.sessionScope )#)" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />	
		--->
	</cffunction>
	
	<cffunction name="onApplicationEnd" hint="" access="public" returntype="void">
		<!--- 
		<cffile output="#now()#: onApplicationEnd" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />
		--->
	</cffunction>
	
	<cffunction name="onError" hint="" access="public" returntype="void">
		<cfargument name="theException" required="true" />
   		<cfargument name="theEventName" type="String" required="true" />
		<!--- 
		<cffile output="#now()#: onError" action="append" file="#getDirectoryFromPath( getCurrentTemplatePath() )#log.txt" addnewline="true" />	
		--->
		<cfdump var="#arguments.theException#" label="onError Exception Dump">
		<cfdump var="#arguments.theEventName#" label="onError Event Name">
		<cfabort>   	
	</cffunction>
		
</cfcomponent>