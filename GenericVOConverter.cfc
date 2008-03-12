<!---
LICENSE 
Copyright 2008 Brian Kotek

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

File Name: 

	GenericVOConverter.cfc
	
Version: 1.0	

Description: 

	This generic converter will attempt to convert the specified data into one or more Value Objects.

Usage:
	
	This converter must have a metadata structure passed into it, containing at minimum a key of "vo" which specifies
	the full type path of the Value Object to create and populate.
		
	If the data passed in is a query, the converter will loop over the query and create an array of Value Objects of the
	specified type. The query column names need to match the argument names defined in the Value Object's init() method.
	
	If the data passed in is an array of structures, the converter will loop over the array and create an array of Value 
	Objects of the specified type. The structure key names need to match the argument names defined in the Value Object's 
	init() method.
	
	If the data passed in is a structure, the converter will create a single Value Object of the specified type. The 
	structure key names need to match the argument names defined in the Value Object's init() method.
		
--->

<cfcomponent output="false" displayname="GenericVOConverter" hint="">
	
	<cffunction name="init" returntype="any" output="false" access="public" hint="Constructor">
		<cfset var local = StructNew() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="convert" access="public" returntype="any" output="false" hint="">
		<cfargument name="data" type="any" required="true" />
		<cfargument name="metadata" type="struct" required="true" />
		<cfargument name="methodName" type="string" required="true" />
		<cfset var local = StructNew() />
		<cfset local.voArray = ArrayNew(1) />

		<cfif IsQuery(arguments.data)>
			
			<cfset local.rowCounter = 1 />
			<cfloop query="arguments.data">
				<cfset local.tempData = StructNew() />
				<cfloop list="#arguments.data.columnList#" index="local.thisColumn">
					<cfset local.tempData[local.thisColumn] = arguments.data[local.thisColumn][local.rowCounter] />
				</cfloop>
				<cfset ArrayAppend(local.voArray, CreateObject('component', arguments.metadata.vo).init(argumentCollection=local.tempData)) />
				<cfset local.rowCounter++ />
			</cfloop>
		
		<cfelseif IsArray(arguments.data)>
			
			<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.thisElement">
				<cfset ArrayAppend(local.voArray, CreateObject('component', arguments.metadata.vo).init(argumentCollection=arguments.data[local.thisElement])) />
			</cfloop>
		
		<cfelseif IsStruct(arguments.data)>
			
			<cfset local.voArray = CreateObject('component', arguments.metadata.vo).init(argumentCollection=arguments.data) />
			
		<cfelse>
			<cfthrow type="GenericVOConverter.UnsupportedDataType" message="The data passed to the GenericVOConverter is of an unknown type and could not be converted." />
		</cfif>
		
		<cfreturn local.voArray />
	</cffunction>

</cfcomponent>

