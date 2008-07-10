To work out of the box, install the examples in a folder named "/beanutils/example". 
Otherwise you will need to modify the values set in the Application.cfc which set the
package names and paths.

Also, by default the example for the MetadataAwareRemoteFactoryBean uses a web service
URL of "http://localhost:8500/beanutils/example/RemoteUserService.cfc?wsdl". If your
server name or path are different, change that to match your configuration. 

That should be all you need to make things work. If anyone runs into problems please
contact me so that I can fix it.