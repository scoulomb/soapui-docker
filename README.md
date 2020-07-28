[![Build Status](https://travis-ci.com/scoulomb/soapui-docker.svg?branch=master)](https://travis-ci.com/scoulomb/soapui-docker)

[Dockerhub](https://hub.docker.com/r/scoulomb/soapui-docker).
# README

A Docker image to run Soap UI non-regression. 

To be used as an alternative of SoapUI official docker image which requires Soap UI Pro floating licence:
- https://support.smartbear.com/readyapi/docs/integrations/docker/soapui.html
- https://github.com/SmartBear/docker-soapui-testrunner

We will build our own soap-ui docker image using soap-ui binaries:
https://www.soapui.org/downloads/soapui/soapui-os-older-versions/

which is strictly equivalent to the paying one, and show how to compose to simplify volume mapping (would work with official image too).


## Idea and why we do that

Idea is to contenairize the `SoapUI` non regression so that it can be runned as a Kubernetes cronjob.
It would be also possible to run the non regression as part of the continous delivery once it is dockerized (jenkins docker driver or using travis with docker or compose).

We show here how to use travis for CI/CD.

This is a POC.


## User guide

### Docker
Image is pushed at every commit on master to [Dockerhub](https://hub.docker.com/r/scoulomb/soapui-docker).

We can run the image using [`docker run`](https://docs.docker.com/docker-hub/builds/advanced/).
````shell script
bash
docker pull scoulomb/soapui-docker
docker run --privileged\
       -v $(pwd)/project_file:/project_file -v $(pwd)/test_results:/test_results scoulomb/soapui-docker -M -f /test_results "/project_file/REST-Project-2-soapui-project.xml"        
````
 
- `-v` is used to [bind mount a volume](https://docs.docker.com/engine/reference/commandline/run/).
    - `./project_file` contains your soapui xml project (in example xml file name is `REST-Project-2-soapui-project.xml`).
    - `./test_results` will contain generated report

We can display the report in 

````shell script
cat ./test_results/test_case_run_log_report.xml
# or with docker
docker run --privileged\
       -v $(pwd)/test_results:/test_results busybox  cat /test_results/test_case_run_log_report.xml

````

<!--
Ordre lecture original c est le contributor guide avec ajout de user guide.
-->

### Docker compose

It is also possible to use compose instead, this avoid manual volume mapping:
This will build, map I/O volumes and run docker image with sample non regression.

````shell script
docker-compose -f docker-compose-dockerhub.yaml up non-regression 
docker-compose -f docker-compose-dockerhub.yaml up cat-report
````

### Sample file

The example is using `project-2` which is a successful SOAPU UI non reg.
We can replace `project-2` by `project-1` where `project-1` is failing (one test passing and one test failing).

In this a sample reports with `project-2` is committed under `test_results/sample`

 ### Adaptation 
 
 Copy your SoapUI XML file to `/project_file` folder, and adapt the name in command given to the docker image:
 `"/project_file/REST-Project-2-soapui-project.xml"`, in `docker run` or `docker-compose` file here:
 `command: ["-M", "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]`

 
## Contributor guide 

### Build locally `Dockerfile` and run it

Same as [user-guide](#user-guide) with those modifications when running in local.

#### Docker

````shell script
bash
docker build . -t non-regression
docker run --privileged\
       -v $(pwd)/project_file:/project_file -v $(pwd)/test_results:/test_results non-regression -M -f /test_results "/project_file/REST-Project-2-soapui-project.xml"        
````

#### Docker compose

````shell script
docker-compose up --build non-regression
````

#### Tips 

If no enough disk space to build images. 
Do clean-up with `docker image rm (docker images | grep "<none>" | awk '{ print $3 }' )` (at your risk)
I am using https://travis-ci.com/ in beta and not https://travis-ci.org.
File name should be `.travis.yml` (not yaml)


### Travis 

Goal is to show it is possible to use docker soapui non reg to fail or not the CI/CD.
(so alternative to k8s cronjob)

At every push `docker-compose up --build non-regression` is runned, to ensure build is not broken.

Note we use travis.com in beta and not org. For this allowed travis apps on all the repos.

### Push to dockerhub

Every time we merge to master a new docker image is delivered.
We are using automated build: https://docs.docker.com/docker-hub/builds/.

And not the traditional way where CI/CD is pushing to dockerhub as done here with Travis: https://docs.travis-ci.com/user/docker/#pushing-a-docker-image-to-a-registry.

We could have also used [docker-compose push](https://docs.docker.com/compose/reference/push/).

Note if we push directly to master (no PR), the build would faild and could to docker build failure on Dockerhub side.

### What's next: Leverage this image and deploy it in Kubernetes 

- we can use k8s empty-dir volume (or pv, pvc) with that image or
- Modify this image to:
    - Deliver new docker image with new non reg file (remove input volume mapping)  at each non-reg delivery
    - Send report by email, or push report to a jfrog (remove output volume mapping). A side container could display report in an Apache/Nginx server.
    - In all cases rather than creating a full new image
    We could build a new docker image from this generic image (`FROM scoulomb/soapui-docker`) which is pushed in docker hub. 
    And for instance replace volume mapping by `RUN COPY` etc.... I recommend this option as we would would do this way with the paying version!


### TODO

- Docker tag visioning and versioned delivery


<!--
- For pretty-print of XML: https://stackoverflow.com/questions/16090869/how-to-pretty-print-xml-from-the-command-line. Do not it 
- dockerhub done
- ONLY TODO: compare oth proj (optional)
- Minikube sample ?
-->