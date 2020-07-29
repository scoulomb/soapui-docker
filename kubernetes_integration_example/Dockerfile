FROM scoulomb/soapui-docker
RUN curl -k https://raw.githubusercontent.com/scoulomb/soapui-docker/master/project_file/REST-Project-2-soapui-project.xml --output /project_file/REST-Project-2-soapui-project.xml
RUN cat  /project_file/REST-Project-2-soapui-project.xml

# For non privileged container to access this file when runned in Kubernetes
RUN chmod -R a+rwx /project_file
USER 100002
#

CMD ["-M",  "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]