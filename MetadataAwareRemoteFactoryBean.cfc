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

	MetadataAwareRemoteFactoryBean.cfc
	
Version: 1.0	

Description: 

	This component will automatically create a Remote Proxy component and inject a metadata configuration file into all interceptors
	that are subclasses of AbstractMetadataAwareAdvice. It also provides some convenience features that help reduce the amount
	of XML configuration required to create remote proxy components.

Usage:
	
	To use the MetadataAwareRemoteFactoryBean, you must first create an Advice that extends AbstractMetadataAwareAdvice. Then, you
	set up your ColdSpring XML configuration to use this custom Factory Bean to generate your remote proxy. For example:
	
		<bean id="productService" class="tests.coldspring.metadata.ProductService" />
	
		<bean id="remoteProductService" class="tests.coldspring.metadata.MetadataAwareRemoteFactoryBean" lazy-init="false">
			<property name="interceptorNames">
				<list>
					<value>VOConverterAdvisor</value>
				</list>
			</property>
			<property name="relativePath">
				<value>/tests/coldspring/remote/</value>
			</property>
			<property name="metadataPath">
				<value>/tests/coldspring/metadata/</value>
			</property>
			<property name="advicePackage">
				<value>tests.coldspring.metadata.advices</value>
			</property>
			<property name="beanFactoryName">
	   			<value>beanFactory</value>
			</property>
			<property name="remoteMethodNames">
				<value>*</value>
			</property>
			<property name="targetBeanID">
				<value>productService</value>
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
	
	The properties required to use the MetadataAwareRemoteFactoryBean are:
	
		targetBeanID: 	The ColdSpring bean ID of the bean being proxied.
		advicePackage: 	The package path to the location where the advice(s) are located. This is used to check
					   	that the advice(s) are an instance of type AbstractMetadataAwareAdvice before attempting
					   	to inject the metadata information into the Advice. This does mean that all of your
					   	metadata-aware Advices must be located in the same location.
		relativePath:	The path where the remote proxy file will be written.
	 remoteMethodNames: The names of the methods to expose in the remote proxy.			   	
					   	
	Optional properties are:
		target: 		The bean being proxied. Not necessary if you specify the targetBeanID property (see below).
		serviceName:	The name of the generated remote proxy file. Not necessary if you specify the
						targetBeanID property (see below).
		metadataPath:	The path that the Factory Bean will look in to locate a matching medatadata XML file based
						on the value of the targetBeanID you specified (see below).				   				  
	  interceptorNames: The list of interceptors.
	   beanFactoryName: The name of the variable in the application scope which references the ColdSpring bean factory.
	   					This defaults to "beanFactory".
	
	You might notice that the XML declaration for the remoteProductService does not specify the "target" or "serviceName" properties.
	These are determined automatically based on the new "targetBeanID" property. If you do not specify target, the Factory Bean
	will assume that the target is the bean ID specified as the targetBeanID.  If you do not specify serviceName, the Factory Bean
	will place "Remote" in front of the target bean ID and that will be the name of the Remote Proxy. For example, if you specify
	the targetBeanID as "productService", the remote proxy that will be generated will be named "RemoteProductService". Again, if
	you need to specify your own values, you may.
	
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

<cfcomponent name="MetadataAwareRemoteFactoryBean" extends="coldspring.aop.framework.RemoteFactoryBean" hint="I add Metadata support to Remote Factory Beans.">
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfset super.init() />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="any" output="true">
		<cfset var local = StructNew() />
		<cfif not isConstructed()>
		
			<!--- Default the service name to the name of the target bean ID with 'Remote' appended to the front of it. --->
			<cfif not StructKeyExists(variables, 'serviceName') or not Len(variables.serviceName)>
				<cfset setServiceName('Remote#initCap(getTargetBeanID())#') />
			</cfif>
			
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