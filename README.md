[![Build Status](https://travis-ci.com/scoulomb/soapui-docker.svg?branch=master)](https://travis-ci.com/scoulomb/soapui-docker)

# README

A Docker image to run Soap UI non-regression. 

To be used as an alternative of SoapUI official docker image which requires Soap UI Pro floating licence:
- https://support.smartbear.com/readyapi/docs/integrations/docker/soapui.html
- https://github.com/SmartBear/docker-soapui-testrunner

We will build our own soap-ui docker image using soap-ui binaries:
https://www.soapui.org/downloads/soapui/soapui-os-older-versions/

which is strictly equivalent to the paying one, and add compose to simplify volume mapping (would work with official image too).


## Idea and why we do that

Idea is to contenairize the `SoapUI` non regression so that it can be runned as a Kubernetes cronjob.
It would be also possible to run the non regression as part of the continous delivery once it is dockerized (jenkins docker driver or using travis with docker or compose).

We show here how to use travis for CI/CD.

This is a POC.

## Run in local

````
docker-compose up --build
````

This will build, map I/O volumes and run docker image with sample non regression.

The initial setup is using `project-2` which is a successful non reg..
We can replace `project-2` by `project-1` where `project-1` is failing (one test passing and one test failing).

In this repo sample reports with `project-2` are committed under `test_results/sample`

#### Tips 

If no enough disk space to build images. 
Do clean-up with `docker image rm (docker images | grep "<none>" | awk '{ print $3 }' )` (at your risk)
I am using https://travis-ci.com/ in beta and not https://travis-ci.org.
File name should be `.travis.yml` (not yaml)

## Adaptation to your own non-reg

Dockerfile does not need to be changed.
Edit the `docker-compose` file line 
`command: ["-M", "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]`

To replace `REST-Project-1-soapui-project.xml` by your project file.

A report will be generated in test_results (volume mapping).

## Travis 

Goal is to show it is possible to use docker soapui non reg to fail or not the CI/CD.
(so alternative to k8s cronjob)

We use travis.com in beta and not org. For this allowed travis apps on all the repos.

## What's next: Deploy in Kubernetes 

- Deliver docker image with non reg (remove input volume mapping)
- We could send report by email, this is possible by tweaking dockerfile or push report to a jfrog (remove output volume mapping)
- use empty-dir volumes or pv?
- Have a generic base image 

## TODO

- Deliver in dockerhub
- https://stackoverflow.com/questions/16090869/how-to-pretty-print-xml-from-the-command-line

