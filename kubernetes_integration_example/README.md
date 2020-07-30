[Dockerhub Example](https://hub.docker.com/r/scoulomb/soapui-docker-k8s-sample).

# README

How to use `scoulomb/soapui-docker` base image to run non-regression as a cronjob in k8s.


## Get to know docker image based on `scoulomb/soapui-docker`  

We build a new image [in this folder](./Dockerfile) on top of `scoulomb/soapui-docker` image.
It is doing a curl to get non regression XML file stored in a git repo. 

### Build and Run sample image locally

````shell script
docker build . -t soapui-docker-k8s-sample:0.0.3
docker run -v "/home/scoulomb/dev:/test_results" soapui-docker-k8s-sample:0.0.3 
````

### Sample image is also built automatically on docker hub 

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

### Prereq

Start Minikube (or alternative)

````shell script
sudo minikube start --vm-driver=none
alias k='sudo kubectl'
````

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



### Using a CronJob and send report by email

This will launch launch the non-regression in an init-container sharing a volume with mail-sender which will send the report by email.

Mail-sender docker image is coming from this project: 
- https://github.com/scoulomb/mail-sender

And available here in Dockerhub:
- https://hub.docker.com/r/scoulomb/mail-sender

````shell script
bash 
alias k='sudo kubectl'
k delete -f cronjob_soapui_mail.yaml
k apply -f cronjob_soapui_mail.yaml
watch sudo kubectl get cj
export LAST_POD_NAME=$( k get pods -o wide | grep "nonreg" |  awk '{ print $1 }' | tail -n 1)
echo $LAST_POD_NAME
k logs $LAST_POD_NAME -c nonreg-worker
k logs $LAST_POD_NAME -c report-sender
# check mail: https://mail.google.com/mail/u/1/#inbox
k delete -f cronjob_soapui_mail.yaml
````

<details>
  <summary>Click to expand logs output</summary>

````shell script
[vagrant@archlinux kubernetes_integration_example]$ k logs $LAST_POD_NAME -c nonreg-worker
================================
=
= SOAPUI_HOME = /opt/SoapUI-5.1.2
=
================================
2020-07-31 11:45:06,843 [main] WARN  com.eviware.soapui.SoapUI - Could not find jfxrt.jar. Internal browser will be disabled.
Configuring log4j from [/opt/SoapUI-5.1.2/bin/soapui-log4j.xml]
11:45:06,980 INFO  [DefaultSoapUICore] Creating new settings at [/opt/SoapUI-5.1.2/bin/?/soapui-settings.xml]
SoapUI 5.1.2 TestCase Runner
[...]
11:45:08,156 DEBUG [SoapUIMultiThreadedHttpConnectionManager$SoapUIDefaultClientConnection] Sending request: GET / HTTP/1.1
11:45:08,253 DEBUG [SoapUIMultiThreadedHttpConnectionManager$SoapUIDefaultClientConnection] Receiving response: HTTP/1.1 200 OK
11:45:08,259 DEBUG [HttpClientSupport$SoapUIHttpClient] Connection can be kept alive indefinitely
11:45:08,452 INFO  [SoapUITestCaseRunner] Assertion [Invalid HTTP Status Codes] has status VALID
11:45:08,455 INFO  [SoapUITestCaseRunner] Finished running SoapUI testcase [TestCase 1], time taken: 308ms, status: FINISHED
11:45:08,455 INFO  [SoapUITestCaseRunner] Project [REST Project 2] finished with status [FINISHED] in 721ms


[vagrant@archlinux kubernetes_integration_example]$ k logs $LAST_POD_NAME -c report-sender
robot.deploy@gmail.com
Credential provided
Content-Type: multipart/mixed; boundary="===============3640955436807624254=="
MIME-Version: 1.0
From: robot.deploy@gmail.com
To: robot.deploy@gmail.com
Date: Fri, 31 Jul 2020 11:45:12 +0000
Subject: non reg results

--===============3640955436807624254==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Find attached the report
--===============3640955436807624254==
Content-Type: application/octet-stream; Name="test_case_run_log_report.xml"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="test_case_run_log_report.xml"

PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPGNvbjp0ZXN0Q2FzZVJ1bkxv
ZyB0ZXN0Q2FzZT0iVGVzdENhc2UgMSIgdGltZVRha2VuPSIzMDgiIHN0YXR1cz0iRklOSVNIRUQi
IHRpbWVTdGFtcD0iMjAyMC0wNy0zMSAxMTo0NTowNyIgeG1sbnM6Y29uPSJodHRwOi8vZXZpd2Fy
ZS5jb20vc29hcHVpL2NvbmZpZyI+PGNvbjp0ZXN0Q2FzZVJ1bkxvZ1Rlc3RTdGVwIG5hbWU9IlJF
U1QgUmVxdWVzdCIgdGltZVRha2VuPSIzMDgiIHN0YXR1cz0iT0siIHRpbWVzdGFtcD0iMjAyMC0w
Ny0zMSAxMTo0NTowOCIgZW5kcG9pbnQ9Imh0dHA6Ly93d3cuZ29vZ2xlLmZyLyIgaHR0cFN0YXR1
cz0iMjAwIiBjb250ZW50TGVuZ3RoPSIxMjY5OCIgcmVhZFRpbWU9IjEwMSIgdG90YWxUaW1lPSIy
ODIiIGRuc1RpbWU9IjYzIiBjb25uZWN0VGltZT0iMTA5IiB0aW1lVG9GaXJzdEJ5dGU9Ijk3IiBo
dHRwTWV0aG9kPSJHRVQiIGlwQWRkcmVzcz0iIi8+PC9jb246dGVzdENhc2VSdW5Mb2c+

--===============3640955436807624254==--

sent

````  

</details>
