<cfcomponent name="UserFactory">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="createUser" access="public" returntype="any" output="false" hint="">
		<cfreturn getBeanInjector().autowire(CreateObject('component', 'User').init()) />
	</cffunction>
	
	<cffunction name="getBeanInjector" access="public" returntype="any" output="false" hint="I return the BeanInjector.">
		<cfreturn variables.instance['beanInjector'] />
	</cffunction>
		
	<cffunction name="setBeanInjector" access="public" returntype="void" output="false" hint="I set the BeanInjector.">
		<cfargument name="beanInjector" type="any" required="true" hint="BeanInjector" />
		<cfset variables.instance['beanInjector'] = arguments.beanInjector />
	</cffunction>

</cfcomponent>