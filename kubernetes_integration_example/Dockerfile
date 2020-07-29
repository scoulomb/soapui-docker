FROM scoulomb/soapui-docker
RUN curl -k https://raw.githubusercontent.com/scoulomb/soapui-docker/master/project_file/REST-Project-2-soapui-project.xml --output /project_file/REST-Project-2-soapui-project.xml
RUN cat  /project_file/REST-Project-2-soapui-project.xml
CMD ["-M",  "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]