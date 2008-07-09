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

	MetadataAwareProxyFactoryBean.cfc
	
Version: 1.0	

Description: 

	This component will automatically create a Remote Proxy component and inject a metadata configuration file into all interceptors
	that are subclasses of AbstractMetadataAwareAdvice.

Usage:
	
	To use the MetadataAwareProxyFactoryBean, you must first create an Advice that extends AbstractMetadataAwareAdvice. Then, you
	set up your ColdSpring XML configuration to use this custom Factory Bean to generate your AOP proxy. For example:
	
		<bean id="productService" class="${beanUtilsPackage}.MetadataAwareProxyFactoryBean" lazy-init="true">
			<property name="interceptorNames">
				<list>
					<value>VOConverterAdvisor</value>
				</list>
			</property>
			<property name="target">
				<bean class="tests.coldspring.services.ProductService" />
			</property>
			<property name="targetBeanID">
				<value>productService</value>
			</property>
			<property name="metadataPath">
				<value>/tests/coldspring/metadata/</value>
			</property>
			<property name="advicePackage">
				<value>tests.coldspring.metadata.advices</value>
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
	
	The properties required to use the MetadataAwareProxyFactoryBean are:
	
		target: 		The bean being proxied
		targetBeanID: 	The ColdSpring bean ID of the bean being proxied. If the proxied bean is unnamed (as in
						the example above), simply specify the bean ID you set for the proxy.
		advicePackage: 	The package path to the location where the advice(s) are located. This is used to check
					   	that the advice(s) are an instance of type AbstractMetadataAwareAdvice before attempting
					   	to inject the metadata information into the Advice. This does mean that all of your
					   	metadata-aware Advices must be located in the same location.
					   	
	Optional properties are:
		
		metadataPath:	The path that the Factory Bean will look in to locate a matching medatadata XML file based
						on the value of the targetBeanID you specified (see below).				   				  
	  interceptorNames: The list of interceptors.
		
	The Factory Bean will attempt to locate an XML file named the same as the targetBeanID at the location specified in the
	"metadataPath" property. For example, if you specify the metadataPath as "/mysite/config/" and the targetBeanID as "productService",
	the factory bean will look for a file named "/mysite/config/productservice.xml". This XML file will contain the metadata
	to be used by any advices that inherit from AbstractMetadataAwareAdvice. Alternatively, you may specify a property of
	"metadataConfig" on the Advice itself if you wish to use a different name for your metadata config file.
	
	The Factory Bean will also inject the targetBeanID into the Advice(s), in case the Advice needs to make any decisions based
	what the target bean is. This generally shouldn't be needed by the Advice but it is there for the rare cases where knowing the
	bean ID of the proxied component is useful.
	
	For additional information on using the AbstractMetadataAwareAdvice and the format for the metadata XML file, see the comments 
	in that CFC.	
	
--->

<cfcomponent name="MetadataAwareProxyFactoryBean" extends="coldspring.aop.framework.ProxyFactoryBean" hint="I add Metadata support to Proxy Factory Beans.">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfset super.init() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="any" output="true">
		<cfset var local = StructNew() />
		<cfif not isConstructed()>
		
			<!--- Set the target to the bean referenced by the target bean ID. --->
			<cfif not StructKeyExists(variables, 'target') or not IsObject(variables.target)>
				<cfset setTarget(getBeanFactory().getBean(getTargetBeanID())) />
			</cfif>
			
			<!--- Loop over any advisors and set metadata information on each MetadataAwareAdvice. --->
			<cfloop from="1" to="#ArrayLen(variables.advisorChain)#" index="local.thisAdvisor">
				<cfset local.thisAdvice = variables.advisorChain[local.thisAdvisor].getAdvice() />
				<cfif IsInstanceOf(local.thisAdvice, '#getAdvicePackage()#.AbstractMetadataAwareAdvice')>
					<cfset local.thisAdvice.setBeanID(getTargetBeanID()) />
					<cfif not Len(local.thisAdvice.getMetaDataConfig())>
						<cfset local.thisAdvice.setMetaDataConfig('#getMetaDataPath()##LCase(getTargetBeanID())#.xml') />
					</cfif>
				</cfif>
			</cfloop>
			
		</cfif>
		<cfset local.object = super.getObject() />
		<cfreturn local.object />
	</cffunction>
	
	<cffunction name="getTargetBeanID" access="public" returntype="string" output="false" hint="I return the TargetBeanID.">
		<cfreturn variables['targetBeanID'] />
	</cffunction>
		
	<cffunction name="setTargetBeanID" access="public" returntype="void" output="false" hint="I set the TargetBeanID.">
		<cfargument name="targetBeanID" type="string" required="true" hint="TargetBeanID" />
		<cfset variables['targetBeanID'] = arguments.targetBeanID />
	</cffunction>
	
	<cffunction name="initCap" access="private" returntype="string" output="false" hint="">
		<cfargument name="str" required="yes" type="string">
		<cfreturn Ucase(left(arguments.str,1)) & Mid(arguments.str,2, Len(arguments.str)-1) />
	</cffunction>
	
	<cffunction name="getMetadataPath" access="public" returntype="string" output="false" hint="I return the MetadataPath.">
		<cfreturn variables.instance['metadataPath'] />
	</cffunction>
		
	<cffunction name="setMetadataPath" access="public" returntype="void" output="false" hint="I set the MetadataPath.">
		<cfargument name="metadataPath" type="string" required="true" hint="MetadataPath" />
		<cfset variables.instance['metadataPath'] = arguments.metadataPath />
	</cffunction>
	
	<cffunction name="getAdvicePackage" access="public" returntype="string" output="false" hint="I return the AdvicePackage.">
		<cfreturn variables.instance['advicePackage'] />
	</cffunction>
		
	<cffunction name="setAdvicePackage" access="public" returntype="void" output="false" hint="I set the AdvicePackage.">
		<cfargument name="advicePackage" type="string" required="true" hint="AdvicePackage" />
		<cfset variables.instance['advicePackage'] = arguments.advicePackage />
	</cffunction>
	
</cfcomponent>