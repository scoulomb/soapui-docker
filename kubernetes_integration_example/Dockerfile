FROM scoulomb/soapui-docker

LABEL maintainer="Sylvain Coulombel <sylvaincoulombel@gmail.com>"

RUN curl -k https://raw.githubusercontent.com/scoulomb/soapui-docker/master/project_file/REST-Project-2-soapui-project.xml --output /project_file/REST-Project-2-soapui-project.xml
RUN cat  /project_file/REST-Project-2-soapui-project.xml

# For non privileged container to access this file when runned in Kubernetes
RUN mkdir /test_results
RUN chmod -R a+rwx /project_file
RUN chmod -R a+rwx /test_results
RUN chmod -R a+rwx /opt
USER 100002
#

RUN ls -la /opt/SoapUI-5.1.2/

CMD ["-M",  "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]