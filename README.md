# ColdSpring Bean Utilities #

Author: [Brian Kotek](http://www.briankotek.com/blog)  
Original Hosting: <http://coldspringutils.riaforge.org>  
Migrated to Git: [Josh Curtiss](http://www.crankybit.com)  

Whereas this project is hosted on RIAForge, I've migrated the repository with Brian's permission to Git and GitHub to make it easier to use with modern technologies, such as Git and Bower. 

## Original Documentation ##

Each component listed here has full documentation and usage examples in the comments at the top of each file.

* Updated on 3/22/2009 to include a thread safety patch from Jon Messer.

* Updated on 7/9/2008 to include updates to the AbstractMetadataAwareAdvice and VOConverterAdvice, as well as added the DynamicXMLBeanFactory, MetadataAwareProxyFactoryBean, and MetadataAwareRemoteFactoryBean. I also added an example subdirectory to demonstrate usage of some of the new components.

This package includes a variety of utilities and other useful components to support development using ColdSpring. Each component has a full description in the comments, and I have several blog posts on these at my blog, <http://www.briankotek.com/blog>.

DynamicXMLBeanFactory: This extends the standard DefaultXMLBeanFactory but allows the ability to replace dynamic properties anywhere in the XML file, as well as in imported XML files.

MetadataAwareProxyFactoryBean: This extends the ColdSpring ProxyFactoryBean and automatically injects metadata information into any Advices that extend AbstractMetadataAwareAdvice after the AOP proxy is created.

MetadataAwareRemoteFactoryBean: This extends the ColdSpring RemoteFactoryBean and automatically injects metadata information into any Advices that extend AbstractMetadataAwareAdvice after the remote proxy is created.

BeanInjector.cfc: The component will autowire any other component with ColdSpring-managed beans. Very useful for injecting ColdSpring beans (mainly Singletons) into transient objects.

TDOBeanInjectorObserver.cfc: This component uses the BeanInjector to automatically autowire Transfer Decorator objects with ColdSpring beans. Transfer is an ORM (object-relational mapping) framework for ColdFusion. Using this observer allows your Transfer Decorators to supply much richer behavior and allows them to act as real Business Objects rather than simple data containers for database data.

AbstractMetadataAwareAdvice.cfc: An abstract ColdSpring AOP Advice that leverages an XML file to supply metadata to your Advices. This greatly enhances the capabilities of an Advice because you can supply information that the Advice can act upon that it would otherwise be unaware of.

VOConverterAdvice.cfc: This Advice extends AbstractMetadataAwareAdvice and allows you to specify a converter component that will perform some kind of conversion on the data being returned by the proxied component. It uses the metadata supplied by the superclass to determine what converter to invoke, and passes the metadata into the converter for its use in doing its work.

GenericVOConverter.cfc: This is a generic Value Object converter that can be used by the VOConverterAdvice that will convert queries, arrays, or structures into objects of the type specified by the metadata. It isn't incredibly useful because it currently returns the structure keys in uppercase but it is meant as a starting point for creating your own converters.

ColdSpringXMLUtils.cfc: 
(NOTE THAT THIS COMPONENT IS BEING DEPRECATED IN FAVOR OF THE DYNAMICXMLBEANFACTORY.) 
This component will replace dynamic properties in a ColdSpring XML file with values specified in the passed structure. ColdSpring itself allows for some dynamic properties, but only in certain places in the XML such as constructor argument values. Using this CFC allows you to place dynamic properties anywhere in the XML. It also handles replacing dynamic properties on any imported ColdSpring files that use the `<import>` tag.
