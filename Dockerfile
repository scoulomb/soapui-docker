# https://hub.docker.com/_/openjdk?tab=tags
FROM openjdk:14-jdk

LABEL maintainer="Sylvain Coulombel <sylvaincoulombel@gmail.com>"
ENV SOAP_UI_VERSION 5.1.2
# Use tarball
# 5.6.0 delivery is actually broken
# Proof: https://community.smartbear.com/t5/SoapUI-Open-Source/Soap-UI-5-6-0-tgz-on-Linux-is-broken-FIX-INSIDE/td-p/204960
# I will use an older version which is still compatible with JDK 16

RUN curl http://dl.eviware.com/soapuios/${SOAP_UI_VERSION}/SoapUI-${SOAP_UI_VERSION}-linux-bin.tar.gz --output /opt/SoapUI-${SOAP_UI_VERSION}-linux-bin.tar.gz
RUN tar xvzf /opt/SoapUI-${SOAP_UI_VERSION}-linux-bin.tar.gz -C /opt

WORKDIR /opt/SoapUI-${SOAP_UI_VERSION}/bin/

RUN mkdir /project_file

# https://www.soapui.org/docs/test-automation/running-functional-tests/
ENTRYPOINT ["./testrunner.sh"]  
