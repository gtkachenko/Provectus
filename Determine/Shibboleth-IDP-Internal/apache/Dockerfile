FROM ubuntu:16.04
MAINTAINER Genndiy Tkachenko <gtkachenko@determine.com>

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		apache2 libapache2-mod-jk \
	&& apt-get install -y iputils-ping telnet vim curl \
	&& rm -r /var/lib/apt/lists/*

RUN mkdir -p /etc/apache2/ssl
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY wld_dtm.key /etc/apache2/ssl/
COPY wld_dtm_base64.cer /etc/apache2/ssl/


RUN a2enmod ssl  
RUN a2ensite default-ssl

COPY jk.conf /etcf/apache2/mods-available/jk.conf
COPY workers.properties /etc/libapache2-mod-jk/workers.properties
RUN a2enmod jk

CMD ["apachectl", "-D", "FOREGROUND"]

#EXPOSE 80,443
