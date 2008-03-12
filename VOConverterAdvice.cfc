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

	VOConverterAdvice.cfc
	
Version: 1.0	

Description: 

	This Advice will convert results from a target component into an array of Value Objects using the GenericVOConverter or
	a custom converter specified in the metadata configuration file. For full details on how the metadata is handled, read
	the comments in AbstractMetadataAwareAdvice.cfc. 

Usage:
	
	To use this advice, specify a Value Object type in the metadata with a key of "vo":
	
		<metadata>
			<target name="productService"
					vo="tests.coldspring.metadata.ProductVO" />
		</metadata>
		
	You may optionally specify a custom converter to use in place of the GenericVOConverter by defining a metadata key
	of "converter":
	
		<metadata>
			<target name="productService"
					productVO="tests.coldspring.metadata.ProductVO"
					converter="tests.coldspring.metadata.CustomProductVOConverter" />
		</metadata>	
	
	Note that using the key name of "vo" is only mandatory if you intend to use the GenericVOConverter. When using a
	custom converter, you are free to specify the value object types using whatever key names you wish to make available
	to your custom converter. So in the above example, the CustomProductVOConverter would be expecting a metadata value
	of "productVO" that will contain the type name of the Value Object.
	
	Any custom converter that you create must have a public method named "convert" which accepts arguments named:
	
		data (the data to be converted)
		metadata (a structure)
		methodName (the name of the method being invoked)
		
--->

<cfcomponent output="false" displayname="VOConverterAdvice" hint="" extends="tests.coldspring.metadata.AbstractMetadataAwareAdvice">

	<cffunction name="init" returntype="any" output="false" access="public" hint="Constructor">
		<cfset var local = StructNew() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="invokeMethod" returntype="any" access="public" output="false" hint="">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" hint="" />
		<cfset var local =  StructNew() />
		<cfset local.result = arguments.methodInvocation.proceed() />	
		<cfif StructKeyExists(local, 'result')>
			<cfset local.converterName = "genericVOConverter" />
			<cfset local.metadata = getMetadataForMethod(arguments.methodInvocation) />
			<cfif StructKeyExists(local.metadata, 'converter')>
				<cfset local.converterName = local.metadata.converter />
			</cfif>
			<cfset local.converter = getBeanFactory().getBean(local.converterName) />
			<cfset local.convertedData = local.converter.convert(local.result, local.metadata, arguments.methodInvocation.getMethod().getMethodName()) />
			<cfreturn local.convertedData />
		</cfif>
	</cffunction>
	
</cfcomponent>