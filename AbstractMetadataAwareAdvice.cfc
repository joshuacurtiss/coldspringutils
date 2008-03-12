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

	AbstractMetadataAwareAdvice.cfc
	
Version: 1.0	

Description: 

	This component will make custom metadata available to any advice that extends this component.

Usage:
	
	To use the AbstractMetadataAwareAdvice, create your own advice that extends the AbstractMetadataAwareAdvice. In your
	invokeMethod method, you can obtain the metadata for the current target component and method by calling getMetaDataForMethod().
	For example (obviously this depends on whatever argument name you use for the methodInvocation argument to invokeMethod()):
	
		<cfset local.metadata = getMetadataForMethod(arguments.methodInvocation) />
	
	The result is a structure containing keys for any metadata associated with that component and method. Any metadata elements
	defined for a method will override metadata elements with the same name defined for the whole component. So given an example
	metadata configuration file:
	
		<metadata>
			<target name="productService"
					logVariables="foo,bar,blah"
					vo="tests.coldspring.metadata.ProductVO">
					<method name="getProducts"
            			logVariables="zoo,cthulhu" />
			</target>		
		</metadata>
	
	When any method other than getProducts() is invoked, the structure returned from getMetadataForMethod() would look like:
	
		[key] = [value]
		logVariables = "foo,bar,blah"
		vo = "tests.coldspring.metadata.ProductVO"
		
	But when getProducts() is invoked, the result structure would be:
	
		[key] = [value]
		logVariables = "zoo,cthulhu"
		vo = "tests.coldspring.metadata.ProductVO"
		
	Keep in mind that the methods are limited to methods available in the remote proxy as defined by the
	remoteMethodNames element that you specify when you define the remote proxy in your ColdSpring XML (see example below).
	
	The ColdSpring XML config might look like this:
	
		<bean id="productService" class="tests.coldspring.metadata.ProductService" />
	
		<bean id="remoteProductService" class="coldspring.aop.framework.RemoteFactoryBean" lazy-init="false">
			<property name="interceptorNames">
				<list>
					<value>VOConverterAdvisor</value>
				</list>
			</property>
			<property name="target">
				<ref bean="productService" />
			</property>
			<property name="serviceName">
				<value>RemoteProductService</value>
			</property>
			<property name="relativePath">
				<value>/tests/coldspring/metadata/</value>
			</property>
			<property name="remoteMethodNames">
				<value>*</value>
			</property>
			<property name="beanFactoryName">
	   			<value>BeanFactory</value>
			</property>
		</bean>
		
		<bean id="genericVOConverter" class="tests.coldspring.metadata.GenericVOConverter" />
		
		<bean id="AbstractMetadataAwareAdvice" class="tests.coldspring.metadata.AbstractMetadataAwareAdvice">
			<property name="metadataConfig">
				<value>/tests/coldspring/metadata/advicemetadata.xml</value>
			</property>
		</bean>
		<bean id="VOConverterAdvice" class="tests.coldspring.metadata.VOConverterAdvice" parent="AbstractMetadataAwareAdvice" />
		<bean id="VOConverterAdvisor" class="coldspring.aop.support.NamedMethodPointcutAdvisor">
			<property name="advice">
				<ref bean="VOConverterAdvice" />
			</property>
			<property name="mappedNames">
				<value>*</value>
			</property>
		</bean>
	
	You are free to use any file name you want for the metadata XML configuration, but it must use the following format
	(specifying method elements is optional):
	
		<metadata>
			<target name="{bean ID of target, or, if the target has no ID in ColdSpring, the full type path of the component}"
					{metadataElementName}="{metadataElementValue}">
					<method name="{method name}"
            			{metadataElementName}="{metadataElementValue}" />
			</target>		
		</metadata>
	
--->

<cfcomponent output="false" displayname="AbstractMetadataAwareAdvice" hint="" extends="coldspring.aop.MethodInterceptor">

	<cffunction name="init" returntype="any" output="false" access="public" hint="Constructor">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="invokeMethod" returntype="any" access="public" output="false" hint="">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" hint="" />
		<cfthrow type="AbstractMetadataAwareAdvice.unimplementedMethod" message="Abstract method invokeMethod() must be overridden by a subclass." />
	</cffunction>
	
	<cffunction name="getMetadataForMethod" access="private" returntype="struct" output="false" hint="">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" hint="" />
		<cfset var local = StructNew() />
		<cfset local.targetMetadata = StructNew() />
		<cfset local.metadata = getAdviceMetadata() />
		<cfset local.beanID = getBeanIDFromCache(arguments.methodInvocation.getTarget()) />
		<cfif StructKeyExists(local.metadata, local.beanID)>
			<cfset local.targetMetadata = local.metadata[local.beanID] />
			<cfif StructKeyExists(local.targetMetadata, 'methods') 
				and StructKeyExists(local.targetMetadata.methods, arguments.methodInvocation.getMethod().getMethodName())>
				<cfset local.targetMetadata = local.targetMetadata.methods[arguments.methodInvocation.getMethod().getMethodName()] />	
			</cfif>
		</cfif>
		<cfreturn local.targetMetadata />
	</cffunction>
	
	<cffunction name="getBeanIDFromCache" access="private" returntype="string" output="false" hint="">
		<cfargument name="targetComponent" type="any" required="true" />
		<cfset var local = StructNew() />
		<cfif not StructKeyExists(variables, 'beanIDCache')>
			<cfset variables.beanIDCache = StructNew() />
		</cfif>
		<cfset local.beanType = GetMetaData(arguments.targetComponent).name />
		<cfif not StructKeyExists(variables.beanIDCache, local.beanType)>
			<cfset local.beanID = getBeanFactory().findBeanNameByType(local.beanType) />
			<cfif not Len(local.beanID)>
				<cfset local.beanID = local.beanType />
			</cfif>
			<cfset variables.beanIDCache[local.beanType] = local.beanID />
		</cfif>
		<cfreturn variables.beanIDCache[local.beanType] />
	</cffunction>
	
	<cffunction name="getAdviceMetadata" access="private" returntype="struct" output="false" hint="">
		<cfset var local = StructNew() />
		<cfif not StructKeyExists(variables, 'adviceMetadata')>
			<cfsavecontent variable="local.mappingXML">
				<cfoutput>
					<cfinclude template="#getMetadataConfig()#" />
				</cfoutput>
			</cfsavecontent>
			<cfset local.metadataXML = XMLParse(Trim(local.mappingXML)) />
			<cfset local.targets = XMLSearch(local.metadataXML, '/metadata/target') />
			<cfset local.adviceMetadata = StructNew() />
			<cfloop from="1" to="#ArrayLen(local.targets)#" index="local.thisTarget">
				<cfset local.thisTargetData = StructNew() />
				<cfset local.tempTarget = local.targets[local.thisTarget] />
				<cfset local.thisTargetData[local.tempTarget.xmlAttributes.name] = StructNew() />
				<cfset StructAppend(local.thisTargetData[local.tempTarget.xmlAttributes.name], local.tempTarget.xmlAttributes)>
				<cfif StructKeyExists(local.tempTarget, 'xmlChildren') and ArrayLen(local.tempTarget.xmlChildren)>
					<cfset local.thisMethodData = StructNew() />
					<cfset local.thisTargetData[local.tempTarget.xmlAttributes.name]['methods'] = StructNew() />
					<cfloop from="1" to="#ArrayLen(local.tempTarget.xmlChildren)#" index="local.thisMethod">
						<cfset local.tempMethod = local.tempTarget.xmlChildren[local.thisMethod] />
						<cfset local.thisMethodData[local.tempMethod.xmlAttributes.name] = StructNew() />
						<cfset StructAppend(local.thisMethodData[local.tempMethod.xmlAttributes.name], local.tempTarget.xmlAttributes) />
						<cfset StructAppend(local.thisMethodData[local.tempMethod.xmlAttributes.name], local.tempMethod.xmlAttributes ) />
						<cfset StructAppend(local.thisTargetData[local.tempTarget.xmlAttributes.name].methods, local.thisMethodData) />
					</cfloop>
				</cfif>
				<cfset StructAppend(local.adviceMetadata, local.thisTargetData)>
			</cfloop>
			<cfset variables.adviceMetadata = local.adviceMetadata />
		</cfif>
		<cfreturn variables.adviceMetadata />
	</cffunction>
	
	<cffunction name="getMetadataConfig" access="public" returntype="string" output="false" hint="I return the MetadataConfig.">
		<cfreturn variables.instance.metadataConfig />
	</cffunction>
		
	<cffunction name="setMetadataConfig" access="public" returntype="void" output="false" hint="I set the MetadataConfig.">
		<cfargument name="metadataConfig" type="string" required="true" hint="MetadataConfig" />
		<cfset variables.instance.metadataConfig = arguments.metadataConfig />
	</cffunction>
	
	<!--- Dependency injection methods for Bean Factory. --->
	<cffunction name="getBeanFactory" access="public" returntype="any" output="false" hint="I return the BeanFactory.">
		<cfreturn variables.instance.beanFactory />
	</cffunction>
		
	<cffunction name="setBeanFactory" access="public" returntype="void" output="false" hint="I set the BeanFactory.">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
		<cfset variables.instance.beanFactory = arguments.beanFactory />
	</cffunction>
	
</cfcomponent>