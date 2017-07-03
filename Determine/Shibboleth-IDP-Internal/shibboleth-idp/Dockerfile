FROM ubuntu:16.04
MAINTAINER Gennadiy Tkachenko gtkachenko@determine.com

RUN apt-get update && apt-get install -y ntp
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN service ntp start && ntpd -q
RUN mkdir /apps

WORKDIR /apps

COPY jdk-8u131-linux-x64.tar.gz /apps
RUN  tar xzf jdk-8u131-linux-x64.tar.gz && rm -f jdk-8u131-linux-x64.tar.gz
COPY cacerts /apps/jdk1.8.0_131/jre/lib/security/cacerts

COPY apache-tomcat-8.5.15.tar.gz /apps 
RUN tar xzf apache-tomcat-8.5.15.tar.gz && ln -s apache-tomcat-8.5.15 tomcat && rm -f apache-tomcat-8.5.15.tar.gz
COPY jstl-1.2.jar /apps/tomcat/lib/
COPY server.xml /apps/tomcat/conf/
COPY ssocert /apps/tomcat/conf/
COPY ssoclient.cer /apps/tomcat/conf/

COPY shibboleth-identity-provider-3.3.1.tar.gz /apps
COPY shibboleth-identity-provider-3.3.1.tar.gz /opt
RUN  tar xzf /opt/shibboleth-identity-provider-3.3.1.tar.gz && rm -f /opt/shibboleth-identity-provider-3.3.1.tar.gz

ENV CATALINA_HOME /apps/tomcat
ENV JAVA_HOME /apps/jdk1.8.0_131

ENV KEYPASS="gfhjkm123" 
ENV SEALPASS="gfhjkm123" 
ENV SCOPE="determine.org"
ENV HOST="idp-shibboleth.$SCOPE" 
ENV ENTITYID="https://$HOST/idp/shibboleth"
RUN cd /apps 
ENV DIST="/apps/shibboleth-identity-provider-3.3.1" 
ENV IDP_HOME="/opt/shibboleth-idp" 
RUN echo \# Properties controlling the installation of the Shibboleth IdP>$DIST/idp.install.properties 
ENV SFILE="$DIST/idp.merge.properties"
RUN 	idp.scope=$SCOPE>>$SFILE ; \
	echo idp.entityID=$ENTITYID>>$SFILE ; \
	echo idp.sealer.storePassword=$SEALPASS>>$SFILE ; \
	echo idp.sealer.keyPassword=$SEALPASS>>$SFILE ; \
	$DIST/bin/install.sh \
		-Didp.property.file=idp.install.properties \
       		-Didp.merge.properties=idp.merge.properties \
       		-Didp.src.dir=$DIST \
       		-Didp.target.dir=$IDP_HOME \
       		-Didp.scope=$SCOPE \
       		-Didp.host.name=$HOST \
       		-Didp.keystore.password=$KEYPASS \
       		-Didp.sealer.password=$SEALPASS \
       		-Didp.noprompt=true 

COPY jstl-1.2.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/jstl-1.2.jar
RUN /opt/shibboleth-idp/bin/build.sh -Didp.target.dir=/opt/shibboleth-idp
COPY wld_chain_dtm_base64.p7b /opt/shibboleth-idp/credentials/wld_chain_dtm_base64.p7b
COPY idp.xml /opt/shibboleth-idp/conf/Catalina/localhost/idp.xml
COPY access-control.xml /opt/shibboleth-idp/conf/access-control.xml
COPY attribute-filter.xml /opt/shibboleth-idp/conf/attribute-filter.xml
COPY attribute-resolver.xml /opt/shibboleth-idp/conf/attribute-resolver.xml
COPY idp.properties /opt/shibboleth-idp/conf/idp.properties
COPY ldap.properties /opt/shibboleth-idp/conf/ldap.properties
COPY metadata-providers.xml /opt/shibboleth-idp/conf/metadata-providers.xml
COPY relying-party.xml /opt/shibboleth-idp/conf/relying-party.xml
COPY saml-nameid.properties /opt/shibboleth-idp/conf/saml-nameid.properties
COPY saml-nameid.xml /opt/shibboleth-idp/conf/saml-nameid.xml

COPY cloud-clm-metadata.xml /opt/shibboleth-idp/metadata/cloud-clm-metadata.xml
COPY idp-metadata.xml /opt/shibboleth-idp/metadata/idp-metadata.xml

COPY server.xml /opt/shibboleth-idp/conf/server.xml
COPY web.xml /opt/shibboleth-idp/conf/web.xml
ENV CATALINA_BASE /opt/shibboleth-idp

CMD ["/apps/tomcat/bin/catalina.sh", "run"]

