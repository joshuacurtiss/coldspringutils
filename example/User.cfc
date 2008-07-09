<cfcomponent name="User">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfset variables.instance['firstName'] = 'Brian' />
		<cfset variables.instance['lastName'] = 'Kotek' />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getFirstName" access="public" returntype="string" output="false" hint="I return the FirstName.">
		<cfreturn variables.instance['firstName'] />
	</cffunction>
		
	<cffunction name="setFirstName" access="public" returntype="void" output="false" hint="I set the FirstName.">
		<cfargument name="firstName" type="string" required="true" hint="FirstName" />
		<cfset variables.instance['firstName'] = arguments.firstName />
	</cffunction>
	
	<cffunction name="getLastName" access="public" returntype="string" output="false" hint="I return the LastName.">
		<cfreturn variables.instance['lastName'] />
	</cffunction>
		
	<cffunction name="setLastName" access="public" returntype="void" output="false" hint="I set the LastName.">
		<cfargument name="lastName" type="string" required="true" hint="LastName" />
		<cfset variables.instance['lastName'] = arguments.lastName />
	</cffunction>
	
	<cffunction name="getUserService" access="public" returntype="any" output="false" hint="I return the UserService.">
		<cfreturn variables.instance['userService'] />
	</cffunction>
		
	<cffunction name="setUserService" access="public" returntype="void" output="false" hint="I set the UserService.">
		<cfargument name="userService" type="any" required="true" hint="UserService" />
		<cfset variables.instance['userService'] = arguments.userService />
	</cffunction>
	
</cfcomponent>