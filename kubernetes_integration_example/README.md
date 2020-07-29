# README

How to use `scoulomb/soapui-docker` base image to run non-regression as a cronjob in k8s.


## Docker image based on `scoulomb/soapui-docker`  


````shell script
sudo docker build . -t soapui-docker-k8s-sample
docker run soapui-docker-k8s-sample
````

<!--
sudo docker tag soapui-docker-k8s-sample scoulomb/soapui-docker-k8s-sample
docker login --username scoulomb
sudo docker push scoulomb/soapui-docker-k8s-sample
--> 