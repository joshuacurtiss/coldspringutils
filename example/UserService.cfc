<cfcomponent name="UserService">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getUser" access="public" returntype="any" output="false" hint="">
		<cfreturn getUserFactory().createUser() />
	</cffunction>
	
	<cffunction name="getUserFactory" access="public" returntype="any" output="false" hint="I return the UserFactory.">
		<cfreturn variables.instance['userFactory'] />
	</cffunction>
		
	<cffunction name="setUserFactory" access="public" returntype="void" output="false" hint="I set the UserFactory.">
		<cfargument name="userFactory" type="any" required="true" hint="UserFactory" />
		<cfset variables.instance['userFactory'] = arguments.userFactory />
	</cffunction>

</cfcomponent>