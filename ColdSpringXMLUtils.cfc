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

	ColdSpringXMLUtils.cfc
	
Version: 1.01

Description: 

	This component will replace dynamic properties in a ColdSpring XML file with
	values specified in the passed structure. ColdSpring itself allows for some
	dynamic properties, but only in certain places in the XML such as constructor
	argument values. Using this CFC allows you to place dynamic properties anywhere
	in the XML. It also will handle including and replacing dynamic properties
	in any included ColdSpring files that use <include> tag.
	
Requirements:

	Because the ColdSpring XML file can be quite sizable in large applications, this
	component uses a Java StringBuilder to avoid using up large amounts of memory
	while doing the replacements. As a result, this component must be used on a
	server that is running Java 5 or later. Most installations of ColdFusion 7 or 8
	should be running at least Java 5 so this should not affect many people.	
	
Usage:

	Usage of the ColdSpringXMLUtils is fairly straightforward. An original ColdSpring XML 
	file might contain an element like this:
		
		<bean id="userService" class="myapp.components.services.userService" />
		
	Using this CFC, you could make part or all of the class name dynamic, like this:
	
		<bean id="userService" class="${servicePackage}.userService" />
	
	You would then define a data structure to map the dynamic properties to the values
	that you want:
	
	<cfscript>
	dynamicProperties = StructNew();
	dynamicProperties.servicePackage = "myapp.components.services";
	</cfscript>
	
	Then simply use this CFC to create the bean factory like this:
	
	<cfset coldSpringXMLUtils = CreateObject('component', 'path.to.ColdSpringXMLUtils').init() />
	<cfset beanFactory = coldSpringXMLUtils.loadDynamicColdSpring("/myapp/config/coldspring.xml", dynamicProperties) />
	
	This component will replace any matching dynamic properties in the XML, create the 
	bean factory, and return it for you to use.	
		
--->

<cfcomponent name="ColdSpring XML Utilities" hint="I am a utility that replaces dynamic properties anywhere in a ColdSpring XML file.">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadDynamicColdSpring" access="public" returntype="any" output="false" hint="I replace any dynamic properties in the specified ColdSpring XML file and return the bean factory.">
		<cfargument name="coldSpringXMLPath" type="string" required="true" hint="Path to ColdSpring XML File i.e. '/myapp/config/coldspring.xml'" />
		<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="Structure containing the dynamic properties to be replaced. The key names must match the dynamic properties in the XML file." />
		<cfset var local = StructNew() />
		<cfset local.beanFactory = CreateObject('component', 'coldspring.beans.DefaultXmlBeanFactory').init(defaultProperties=arguments.properties) />
		<cfset local.replacedColdSpringXML = getReplacedColdSpringXML(arguments.coldSpringXMLPath, arguments.properties) />
		<cfset local.beanFactory.loadBeansFromXmlRaw(beanDefinitionXml=local.replacedColdSpringXML, constructNonLazyBeans=true) />
		<cfreturn local.beanFactory />
	</cffunction>
	
	<cffunction name="getReplacedColdSpringXML" access="public" returntype="string" output="false" hint="I return the ColdSpring XML with all imports processed and dynamic properties replaced.">
		<cfargument name="coldSpringXMLPath" type="string" required="true" hint="Path to ColdSpring XML File i.e. '/myapp/config/coldspring.xml'" />
		<cfargument name="properties" type="struct" required="false" default="#StructNew()#" hint="Structure containing the dynamic properties to be replaced. The key names must match the dynamic properties in the XML file." />
		<cfset var local = StructNew() />
		<cfset local.imports = StructNew() />
		<cfset local.beanFactory = CreateObject('component', 'coldspring.beans.DefaultXmlBeanFactory').init() />
		<cfset local.beanFactory.findImports(local.imports, arguments.coldSpringXMLPath) />
		<cfif StructCount(local.imports) eq 1>
			<cfset arguments.coldSpringXMLPath = ExpandPath(arguments.coldSpringXMLPath) />
			<cfset local.replacedColdSpringXML = replaceDynamicValues(arguments.coldSpringXMLPath, arguments.properties) />		
		<cfelseif StructCount(local.imports) gt 1>
			<cfset local.replacedXMLArray = ArrayNew(1) />
			<cfloop collection="#local.imports#" item="local.thisImport">
				<cfset local.tempImportData = StructNew() />
				<cfset local.tempImportData.importFile = local.thisImport />
				<cfset local.tempImportData.replacedXML = replaceDynamicValues(local.thisImport, arguments.properties) />
				<cfset ArrayAppend(local.replacedXMLArray, local.tempImportData) />
			</cfloop>
			<cfset local.replacedColdSpringXML = '<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springframework.org/dtd/spring-beans.dtd">#Chr(13)##Chr(10)#<beans>#Chr(13)##Chr(10)##Chr(13)##Chr(10)#' />
			<cfloop from="1" to="#ArrayLen(local.replacedXMLArray)#" index="local.thisXML">
				<cfset local.replacedColdSpringXML = local.replacedColdSpringXML & '#Chr(13)##Chr(10)##Chr(9)#<!-- @import processed from #local.replacedXMLArray[local.thisXML].importFile# -->#Chr(13)##Chr(10)#' & ReReplaceNoCase(local.replacedXMLArray[local.thisXML].replacedXML, '.*<beans>|<import[^>]*>|</beans>', '', 'All') />	
			</cfloop>			
			<cfset local.replacedColdSpringXML = local.replacedColdSpringXML & '</beans>' />
		</cfif>
		<cfreturn local.replacedColdSpringXML />
	</cffunction>
	
	<cffunction name="replaceDynamicValues" access="private" returntype="string" output="false" hint="I replace any dynamic values in the ColdSpring XML with matching values in the specified value structure">
		<cfargument name="coldSpringXMLPath" type="string" required="true" hint="Path to ColdSpring XML File i.e. '/myapp/config/coldspring.xml'" />
		<cfargument name="dynamicValues" type="struct" required="false" default="#StructNew()#" hint="Structure containing the dynamic properties to be replaced. The key names must match the dynamic properties in the XML file." />
		<cfset var local = StructNew() />
		<cffile action="read" file="#arguments.coldSpringXMLPath#" variable="local.coldSpringXML" />
		<cfset local.matches = ReMatchNoCase('\$\{[^}]*\}', local.coldSpringXML) />
		<cfset local.stringBuilder = CreateObject("java","java.lang.StringBuilder").init(JavaCast("string", local.coldSpringXML)) />
		<cfoutput>
		<cfloop from="1" to="#ArrayLen(local.matches)#" index="local.thisMatch">
			<cfset local.tempString = Mid(local.matches[local.thisMatch], 3, Len(local.matches[local.thisMatch]) - 3) />
			<cfif StructKeyExists(arguments.dynamicValues, local.tempString)>
				<cfset replaceValue(local.stringBuilder, local.matches[local.thisMatch], arguments.dynamicValues[local.tempString]) />
			</cfif>
		</cfloop>
		</cfoutput>
		<cfreturn local.stringBuilder.toString() />
	</cffunction>
	
	<cffunction name="replaceValue" access="private" returntype="void" output="false" hint="I recursively replace the specified dynamic property in the XML.">
		<cfargument name="stringBuffer" type="any" required="true" />
		<cfargument name="targetString" type="string" required="true" />
		<cfargument name="replacementValue" type="string" required="true" />
		<cfargument name="startPosition" type="numeric" required="false" default="0" />
		<cfset var local = StructNew() />
		<cfset local.stringIndex = arguments.stringBuffer.indexOf(JavaCast("string", arguments.targetString), JavaCast("int", arguments.startPosition)) />
		<cfif local.stringIndex neq -1>
			<cfset arguments.stringBuffer.replace(JavaCast("int", local.stringIndex), JavaCast("int", local.stringIndex + Len(arguments.targetString)), JavaCast("string", arguments.replacementValue)) />
			<cfset replaceValue(arguments.stringBuffer, arguments.targetString, arguments.replacementValue, local.stringIndex + Len(arguments.targetString)) />
		</cfif>
	</cffunction>
	
</cfcomponent>