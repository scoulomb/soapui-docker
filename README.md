[![Build Status](https://travis-ci.com/scoulomb/soapui-docker.svg?branch=master)](https://travis-ci.com/scoulomb/soapui-docker)

# README

A Soap UI docker image to run non regression in Kubernetes.
To be used as an alternative of SoapUI official docker image which requires Soap UI floating licence. 

## Idea

Idea is to contenairize the `SoapUI` non regression so that it can be runned with Kubernetes cronjob.

We could use SoapUI docker image: https://github.com/SmartBear/docker-soapui-testrunner
But it requires a SoapUI floating licence and thus SoapUI pro.

So we will do our own !

Here here is a POC where we build our own SoapUI docker image.

## Run 

````
docker-compose up --build
````

This will build, map I/O volumes and run docker image with sample non regression (using project-2 which is successful).

We can replace `project-2` by `project-1`. `project-1` is failing (one test passing and one test failing).


In this repo sample reports with `project-2` are committed under `test_results/sample`

## Adaptation to your use-case

Dockerfile does not need to be changed.
Edit the `docker-compose` file line 
`command: ["-M", "-f", "/test_results", "/project_file/REST-Project-2-soapui-project.xml"]`

To replace `REST-Project-1-soapui-project.xml` by your project file.

A report will be generated in test_results (volume mapping).

## Travis 

Goal is to show it is possible to use docker soapui non reg to fail or not the CI/CD.

## Tips 

If no enough disk space to build image, 
Do clean-up with `docker image rm (docker images | grep "<none>" | awk '{ print $3 }' )` (at your risk)
I am using https://travis-ci.com/ in beta and not https://travis-ci.org.
File name should be `.travis.yml` (not yaml)

## What's next: Deploy in Kubernetes 

- Deliver docker image with non reg (remove input volume mapping)
- We could send report by email, this is possible by tweaking dockerfile or push report to a jfrog (remove output volume mapping)
- Deliver in dockerhub

## Note

- Project 1 is example of failure
- Project 2 is example of success

Binary for soap-ui were found here:
https://www.soapui.org/downloads/soapui/soapui-os-older-versions/