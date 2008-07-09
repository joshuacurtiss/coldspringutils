<cfcomponent output="false" displayname="UserVOConverter" hint="">
	
	<cffunction name="init" returntype="any" output="false" access="public" hint="Constructor">
		<cfset var local = StructNew() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="convert" access="public" returntype="any" output="false" hint="Converts a User object into a typed struct.">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="metadata" type="struct" required="true" />
		<cfargument name="methodName" type="string" required="true" />
		<cfset var local = StructNew() />
		<cfscript>
		local.userVO = StructNew();
		local.userVO['__type__'] = arguments.metadata.userVOType;
		local.userVO['firstName'] = arguments.data.getFirstName();
		local.userVO['lastName'] = arguments.data.getLastName();
		</cfscript>
		<cfreturn local.userVO />
	</cffunction>
		
</cfcomponent>

