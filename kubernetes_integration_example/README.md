# README

How to use `scoulomb/soapui-docker` base image to run non-regression as a cronjob in k8s.


## Get to know docker image based on `scoulomb/soapui-docker`  

### Build and Run locally

````shell script
docker build . -t soapui-docker-k8s-sample:0.0.3
docker run -v "/home/scoulomb/dev:/test_results" soapui-docker-k8s-sample:0.0.3 
````

### Image is built automatically on docker hub 

The image `soapui-docker-k8s-sample` is built automatically from this Dockerfile in dockerhub.
https://hub.docker.com/repository/docker/scoulomb/soapui-docker-k8s-sample

<!--
sudo docker tag soapui-docker-k8s-sample scoulomb/soapui-docker-k8s-sample
docker login --username scoulomb
sudo docker push scoulomb/soapui-docker-k8s-sample

I had error: denied: requested access to the resource is denied

So use dockerhub build:
> https://hub.docker.com/repository/docker/scoulomb/soapui-docker-k8s-sample/builds/edit
Dockerfile location: Dockerfile
Build context: /kubernetes_integration_example
if error login/logout in UI
--> 

````shell script
docker pull scoulomb/soapui-docker-k8s-sample
docker run scoulomb/soapui-docker-k8s-sample
````

## Run it in Kubernetes

### With a pod 

#### Locally built image
 
It is possible to use image built locally by changing `imagePullPolicy` to `never`.

````shell script
k delete po non-reg-sample --force --grace-period=0
k run non-reg-sample --image=soapui-docker-k8s-sample:0.0.3 --image-pull-policy=Never
k logs  non-reg-sample
````

<!--
I had made a stupid mistake here making me crazy:
`k run non-reg-sample run --image=soapui-docker-k8s-sample:0.0.3 --image-pull-policy=Never``
run twice, it was overriding the command
-->

Output is:

````shell script
➤ k logs  non-reg-sample                                                                                                                                                      scoulomb@linux================================
=
= SOAPUI_HOME = /opt/SoapUI-5.1.2
=
================================
2020-07-29 10:17:45,689 [main] WARN  com.eviware.soapui.SoapUI - Could not find jfxrt.jar. Internal browser will be disabled.
Configuring log4j from [/opt/SoapUI-5.1.2/bin/soapui-log4j.xml]
10:17:45,824 INFO  [DefaultSoapUICore] Creating new settings at [/opt/SoapUI-5.1.2/bin/?/soapui-settings.xml]
SoapUI 5.1.2 TestCase Runner
[...]
10:17:47,118 INFO  [SoapUITestCaseRunner] Assertion [Invalid HTTP Status Codes] has status VALID
10:17:47,120 INFO  [SoapUITestCaseRunner] Finished running SoapUI testcase [TestCase 1], time taken: 314ms, status: FINISHED
10:17:47,123 INFO  [SoapUITestCaseRunner] Project [REST Project 2] finished with status [FINISHED] in 653ms
````



#### Dockerhub

````shell script
k delete po non-reg-sample --force --grace-period=0
k run non-reg-sample --image=scoulomb/soapui-docker-k8s-sample
k logs  non-reg-sample
````

### Using a [CronJob](https://github.com/scoulomb/myk8s/blob/master/Master-Kubectl/1-kubectl-create-explained-ressource-derived-from-pod.md#create-a-cronjob)

````shell script
k create cronjob nonreg-cronjob --image  scoulomb/soapui-docker-k8s-sample --schedule="* * * * *"  
````

Output is:

````shell script
[10:33][master]⚡ ~/dev/soapUI-docker/kubernetes_integration_example
➤ k create cronjob nonreg-cronjob --image  scoulomb/soapui-docker-k8s-sample --schedule="* * * * *"                                                                           scoulomb@linux

cronjob.batch/nonreg-cronjob created
[10:33][master]⚡ ~/dev/soapUI-docker/kubernetes_integration_example
➤ k get cronjob                                                                                                                                                               scoulomb@linux
NAME             SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
nonreg-cronjob   * * * * *   False     0        28s             2m32s
[10:36][master]⚡ ~/dev/soapUI-docker/kubernetes_integration_example
[10:37][master]⚡ ~/dev/soapUI-docker/kubernetes_integration_example
➤ k get jobs                                                                                                                                                                  scoulomb@linux
NAME                        COMPLETIONS   DURATION   AGE
nonreg-cronjob-1596018900   1/1           5s         2m18s
nonreg-cronjob-1596018960   1/1           8s         78s
nonreg-cronjob-1596019020   1/1           6s         17s
➤ k get pods                                                                                                                                                                  scoulomb@linux
NAME                              READY   STATUS      RESTARTS   AGE
nonreg-cronjob-1596018840-hht6p   0/1     Completed   0          2m30s
nonreg-cronjob-1596018900-8fl6s   0/1     Completed   0          90s
nonreg-cronjob-1596018960-xgpgn   0/1     Completed   0          30s
[10:36][master]⚡ ~/dev/soapUI-docker/kubernetes_integration_example
➤ k logs nonreg-cronjob-1596018900-8fl6s                                                                                                                                      scoulomb@linux
================================
=
= SOAPUI_HOME = /opt/SoapUI-5.1.2
[...]
10:35:08,850 INFO  [SoapUITestCaseRunner] Finished running SoapUI testcase [TestCase 1], time taken: 239ms, status: FINISHED
10:35:08,855 INFO  [SoapUITestCaseRunner] Project [REST Project 2] finished with status [FINISHED] in 623ms
````

Use `--dry-run -o yaml`, to create Helm templates.
 
For report sending we could adapt this image to send email and more.

<!--
I am not sure using fluentd logger to access report would work as job is ephemeral
https://github.com/scoulomb/myk8s/blob/6e6de11afe4fd78b761d785ecab80de021b7814e/Volumes/fluentd-tutorial.md
-->
