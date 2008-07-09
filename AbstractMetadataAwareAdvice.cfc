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
	
Version: 1.1	

Description: 

	This component will make custom metadata available to any advice that extends this component. Note that it works best when used
	in conjunction with a MetadataAwareFactoryBean that is able to inject the bean ID (i.e. the bean "name") into this component
	to assist in looking up the correct metadata XML file. This is because it is impossible to determine the bean ID of a proxied
	component with certainty. While this CFC will make its best guesses at what ColdSpring bean is being proxied, unless
	you specify the proxied bean ID explicitly there is a chance that it may fail.

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
	
	I recommend using a custom Factory Bean such as a MetadataAwareRemoteFactoryBean or a MetadataAwareProxyFactory Bean,
	the ColdSpring XML may look slightly different. Note the remoteProductService's class is now the custom Factory Bean,
	and that the Advice is not specifying an additional property which is the beanID being proxied.
	
	The Factory Bean will attempt to locate an XML file named the same as the targetBeanID at the location specified in the
	"metadataPath" property. For example, if you specify the metadataPath as "/mysite/config/" and the targetBeanID as "productService",
	the factory bean will look for a file named "/mysite/config/productservice.xml". This XML file will contain the metadata
	to be used by any advices that inherit from AbstractMetadataAwareAdvice. Alternatively, you may specify a property of
	"metadataConfig" on the Advice itself if you wish to use a different name for your metadata config file.
	
		<bean id="remoteProductService" class="tests.coldspring.metadata.MetadataAwareRemoteFactoryBean" lazy-init="false">
			<property name="interceptorNames">
				<list>
					<value>VOConverterAdvisor</value>
				</list>
			</property>
			<property name="relativePath">
				<value>/tests/coldspring/remote/</value>
			</property>
			<property name="remoteMethodNames">
				<value>*</value>
			</property>
			<property name="beanFactoryName">
	   			<value>BeanFactory</value>
			</property>
			<property name="targetBeanID">
				<value>productService</value>
			</property>
			<property name="metadataPath">
				<value>/tests/coldspring/metadata/</value>
			</property>
			<property name="advicePackage">
				<value>/tests/coldspring/advices/</value>
			</property>
		</bean>
		
		<bean id="genericVOConverter" class="tests.coldspring.metadata.GenericVOConverter" />
		<bean id="VOConverterAdvice" class="tests.coldspring.metadata.VOConverterAdvice" />
		<bean id="VOConverterAdvisor" class="coldspring.aop.support.NamedMethodPointcutAdvisor">
			<property name="advice">
				<ref bean="VOConverterAdvice" />
			</property>
			<property name="mappedNames">
				<value>*</value>
			</property>
		</bean>
	
	If no custom Factory Bean is used, the ColdSpring XML config might look like this:
	
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
				<value>/tests/coldspring/remote/</value>
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
	
	For additional information on using the MetadataAwareRemoteFactoryBean, see the comments in that CFC.	
	
--->

<cfcomponent output="false" displayname="AbstractMetadataAwareAdvice" hint="" extends="coldspring.aop.MethodInterceptor">

	<cfset variables.instance.beanID = "" />
	<cfset variables.instance.metaDataConfig = "" />

	<cffunction name="init" returntype="any" output="false" access="public" hint="Constructor">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="invokeMethod" returntype="any" access="public" output="false" hint="" throws="custom.AbstractMetadataAwareAdvice.UnimplementedMethod">
		<cfargument name="methodInvocation" type="coldspring.aop.MethodInvocation" required="true" hint="" />
		<cfthrow type="custom.AbstractMetadataAwareAdvice.UnimplementedMethod" message="Abstract method invokeMethod() must be overridden by a subclass." />
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
	
	<cffunction name="getBeanType" access="private" returntype="string" output="false" hint="I get the component type from the passed component metadata.">
		<cfargument name="metadata" type="any" required="true" />
		<cfset var local = StructNew() />
		<cfset local.type = "" />
		<cfif not Left(arguments.metadata.name, 28) eq "coldspring.aop.framework.tmp" and StructKeyExists(arguments.metadata, 'functions')>
			<cfloop from="1" to="#ArrayLen(arguments.metadata.functions)#" index="local.thisMethod">
				<cfif arguments.metadata.functions[local.thisMethod].name eq "init">
					<cfset local.type = arguments.metadata.name />
					<cfbreak />
				</cfif>	
			</cfloop>
		</cfif>
		<cfif not Len(local.type) and StructKeyExists(arguments.metadata, 'extends')>
			<cfset local.type = getBeanType(arguments.metadata.extends) />
		</cfif>
		<cfreturn local.type />
	</cffunction>
	
	<cffunction name="getBeanIDFromCache" access="private" returntype="string" output="false" hint="">
		<cfargument name="targetComponent" type="any" required="true" />
		<cfset var local = StructNew() />
		<cfif not StructKeyExists(variables, 'beanIDCache')>
			<cfset variables.beanIDCache = StructNew() />
		</cfif>
		<cfif not Len(getBeanID())>
			<cfset local.beanType = getBeanType(GetMetaData(arguments.targetComponent)) />
		<cfelse>
			<cfset local.beanType = getBeanID() />
		</cfif>
		<cfif not StructKeyExists(variables.beanIDCache, local.beanType)>
			<cfset local.beanID = local.beanType />
			<cfset variables.beanIDCache[local.beanType] = local.beanID />
		</cfif>			
		<cfreturn variables.beanIDCache[local.beanType] />
	</cffunction>
	
	<cffunction name="getAdviceMetadata" access="private" returntype="struct" output="false" hint="">
		<cfset var local = StructNew() />
		<cfif not StructKeyExists(variables, 'adviceMetadata')>
			<cffile action="read" file="#ExpandPath(getMetadataConfig())#" variable="local.mappingXML" />
			<cfset local.metadataXML = XMLParse(Trim(local.mappingXML)) />
			<cfset local.targets = XMLSearch(local.metadataXML, '/metadata/target') />
			<cfset local.adviceMetadata = StructNew() />
			<cfloop from="1" to="#ArrayLen(local.targets)#" index="local.thisTarget">
				<cfset local.thisTargetData = StructNew() />
				<cfset local.tempTarget = local.targets[local.thisTarget] />
				<cfset local.tempName = local.tempTarget.xmlAttributes.name />
				<cfset local.thisTargetData[local.tempName] = StructNew() />
				<cfset StructAppend(local.thisTargetData[local.tempName], local.tempTarget.xmlAttributes)>
				<cfif StructKeyExists(local.tempTarget, 'xmlChildren') and ArrayLen(local.tempTarget.xmlChildren)>
					<cfset local.thisMethodData = StructNew() />
					<cfset local.thisTargetData[local.tempName]['methods'] = StructNew() />
					<cfloop from="1" to="#ArrayLen(local.tempTarget.xmlChildren)#" index="local.thisMethod">
						<cfset local.tempMethod = local.tempTarget.xmlChildren[local.thisMethod] />
						<cfset local.thisMethodData[local.tempMethod.xmlAttributes.name] = StructNew() />
						<cfset StructAppend(local.thisMethodData[local.tempMethod.xmlAttributes.name], local.tempTarget.xmlAttributes) />
						<cfset StructAppend(local.thisMethodData[local.tempMethod.xmlAttributes.name], local.tempMethod.xmlAttributes ) />
						<cfset StructAppend(local.thisTargetData[local.tempName].methods, local.thisMethodData) />
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
	
	<cffunction name="getBeanID" access="public" returntype="string" output="false" hint="I return the BeanID.">
		<cfreturn variables.instance['beanID'] />
	</cffunction>
		
	<cffunction name="setBeanID" access="public" returntype="void" output="false" hint="I set the BeanID.">
		<cfargument name="beanID" type="string" required="true" hint="BeanID" />
		<cfset variables.instance['beanID'] = arguments.beanID />
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