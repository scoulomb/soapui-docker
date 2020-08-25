# Project presentation

<!-- doc st completed -->

## Projects overview
 
Seed: [dockerisation of SoapUI](./README.md).
- Which is used in  [kubernetes_integration_example](./kubernetes_integration_example/Dockerfile): an image based on soapui-docker, using curl to get test XML file rather than arguments/volume, deployed as CronJob with Helm. 
  
  This project ([cf. README](./kubernetes_integration_example/README.md)) relies on two external project:
    
    - mail sender side container: https://github.com/scoulomb/mail-sender: A container to send report via email, using a empty dir volume as a sidecar (init container) with non reg.
    - And to helm deployer: https://github.com/scoulomb/github-page-helm-deployer: A container to deploy helm chart via Docker in CI/CD using travis
      <!--
      Other inter-repo link
      - which is pointing to  https://github.com/scoulomb/myk8s  
      - And to  https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md <-> https://github.com/scoulomb/myDNS/blob/master/2-advanced-bind/5-real-own-dns-application/0-basic-gandi-dns.md
       Where:
          - https://github.com/scoulomb/myDNS/tree/master/2-advanced-bind -> https://github.com/scoulomb/myk8s  
          - https://github.com/scoulomb/myDNS/blob/master/2-advanced-bind/5-real-own-dns-application/0-basic-gandi-dns.md -> https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md
          - https://github.com/scoulomb/dev_resume -> https://scoulomb.github.io/ -> https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md 
          - https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md <-> https://github.com/scoulomb/dns-config
          - https://github.com/scoulomb/aws-prep  -> https://github.com/scoulomb/myPublicCloud/blob/master/AWS/4-DNS-route-53.md (2-modify-tld-ns-record.md,  5-delegate-subzone.md => glue, NS record and custom nameserver) -> https://github.com/scoulomb/myDNS/tree/master/2-advanced-bind/5-real-own-dns-application
                                                  ->  (step 3 in aws prep) https://github.com/scoulomb/aws-sa-exo -> myIaC/myk8s
          - https://github.com/scoulomb/myIaC -> myk8s + mydns
      -->
      
<!--
- private repo contains what is private in this repo (private) and oters
- did not use mail redirection for robot.deploy but could have (https://github.com/scoulomb/dns-config)
- [kubernetes_integration_example](./kubernetes_integration_example/Dockerfile) has no user guide, it is a dev tuto)
--> 

<!-- Inter repo link is OK -->

<!-- Dojo link JM
- SoapUI docker Dojo: had stopped at mail sender
- DNS Dojo 2: Link github page and DNS => https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md
(which is Linked to SoapUI docker (this file) and DNS https://github.com/scoulomb/myDNS/blob/master/2-advanced-bind/5-real-own-dns-application/0-basic-gandi-dns.md)
- DNS Dojo 1: We had review the repo until https://github.com/scoulomb/myDNS/blob/master/1-basic-bind-lxa/p2-2-configure-reverse-zone.md
But we had questions, I completed then in Advanced bind and p1-1
=> (link nameserver to root server, glue, ns) https://github.com/scoulomb/myDNS/blob/master/2-advanced-bind/5-real-own-dns-application/2-modify-tld-ns-record.md
=> (DHCP cache) https://github.com/scoulomb/myDNS/blob/master/1-basic-bind-lxa/p1-1-dns-cache.md (end of doc)

So next with JM could be 
- SoapUI docker suite (with dns overlap) from mail sender: https://github.com/scoulomb/soapui-docker/blob/master/presentation.md
- DNS suite from p2-2 with questions from last time answered (https://github.com/scoulomb/myDNS) in particular link nameserver to root server

Team SoapUI docker Demo ev left -> helm deplyment when jumps cj alone sans helm ([cf. README](./kubernetes_integration_example/README.md)) + this page in mind)
-->

<!--
(we could have kept helm char in same repo as code but need to probably tag ok osef)
-->

## Presentation 

- Follow the README starting from [dockerisation of SoapUI](./README.md) and just show replacement with team non reg in compose. (skip dev guide).
And follow links(<=> [overview](#Projects-overview)).

See [demo effect known issues](kubernetes_integration_example/README.md#known-issues)

## Extensions 

1. We used a [init container](https://docs.bitnami.com/kubernetes/apps/kibana/administration/sidecars-init-containers/) to send an email after report is generated.
Init is the same as side car except it guarantees init container finishes before launching others.

2. With the side container pattern we could have other container to push non reg report to git
The docker image would be very similar to https://github.com/scoulomb/github-page-helm-deployer).
We could also push to to any artifactory (Jfrog).

3. Rather than using init container we could send mail sending directly in [kubernetes_integration_example](./kubernetes_integration_example/Dockerfile).
But using side-container enables genericity and separation of concern (producer of report / consumer of report).

4. Note if reports are pushed to git or artifactory, it could be displayed in a web page.
Using same pattern, a ngnix/container with a shared volume to a side container pulling images from git/artifactory.
It is similar to solution to [deprecate git repo](https://github.com/kubernetes/kubernetes/pull/63445) but not with an init container as we need a poll every X minutes.

5. Also Rather thank dockerizing SaopUI image, we could have dockerized [non regression maven project](https://www.soapui.org/docs/test-automation/maven/maven-2-x/).

<!--
NWA sol 3+4 OK, from compo and OS the same OKOK
-->

<!--
adaptation link [private.md](./private.md)
-->


## Why Dockerisation + CronJob is a good idea

- Everything is in Kubernetes (no dependencies)
- Deliver and non-reg and soft at same time (can use feature branch before merging in master, usage of feature branch also enables to test non reg with code before delivering it (blacklist issue))
- Rather than a CronJob we could also run the non reg in CI (this what is done in [travis file](.travis.yml), it would be similar in Jenkins) 

## Why Helm + Travis + Dockerhub is great 

### Package management basic

It enables to package kubernetes manifest and brings package management.

````shell script
helm repo add soapui https://helm-registry.github.io/soapui
helm search repo soapui
````

Output is

````shell script
[root@archlinux vagrant]# helm search repo soapui
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
soapui/helm-k8s-integration     0.1.0           1.20.0          A Helm chart for Kubernetes
````

### Update flow

I will now update to version 1.21.0 so diff is 

```shell script
# follow Semantic Versioning. They should reflect the version the application is using.
- appVersion: 1.20.0
+ appVersion: 1.21.0
```
And commit is: https://github.com/scoulomb/soapui-docker/commit/c59959ba0f27e148166a092b9de435a5638de43f

From there

#### Travis and helm registry push

Travis based on [Travis file](./.travis.yml) is launching a build which run the non reg (case where non-reg is not runned as CronJob but as part of the non-reg, here it is also testing the project).

And if it is successful, it delivers helm package using [helm deployer](https://github.com/scoulomb/github-page-helm-deployer) in registry. It uses a github token: https://github.com/settings/tokens

This why a new template is delivered here with the good version: https://github.com/helm-registry/helm-registry.github.io/blob/master/soapui/index.yaml

Travis access to repo can be seen here: https://github.com/settings/installations

#### Dockerhub build

Dockerhub is building the Dockerfile, it is allowed here. So Github notify Dockerhub.
There is no need to build image in CI as it is usually done (but could lead to sync issue).
Here we can see the matching commit source: https://hub.docker.com/r/scoulomb/soapui-docker/builds

<!--
https://hub.docker.com/repository/registry-1.docker.io/scoulomb/soapui-docker/builds/e75206e3-121f-4bdc-9b23-1d9143ae7fd1
-->

#### Package update

````shell script
[root@archlinux kubernetes_integration_example]# helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "soapui" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈ Happy Helming!⎈
[root@archlinux kubernetes_integration_example]# helm search repo soapui
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
soapui/helm-k8s-integration     0.1.0           1.21.0          A Helm chart for Kubernetes
````

We can see bersion has been update to 21 (like an `apt-get update`).
We could version the docker and also in helm chart for release management.

#### Note

Travis and Dockerhub need the project to be opened.
Travis is equivalent to Jenkins. Jfrog can support docker repo (but push from CI).

## Alternative and perspective

We could also deploy a Jenkins in k8s (but we are not serverless)

[Jenkins helm repo](https://hub.helm.sh/charts/bitnami/jenkins).
````
sudo minikube start --vm-driver=none
sudo su 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/jenkins
helm uninstall my-release
````


<details>
  <summary>Click to expand expand manual volume provisioning</summary>

We need to define a volume (`k get pvc`) indicates we should have a [persistent volume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/).


````shell script
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  # storageClassName: manual
  volumeMode: Filesystem
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF
kubectl delete -f task-pv-volume
````

</details>

If image pull back off, `sudo systemd-resolve --flush-caches` (vpn)

<!--
did not test fully Jenkins
-->

<!--
image pull at every job  + what about backoff osef
SO question

JM stops: https://github.com/scoulomb/soapui-docker/blob/master/kubernetes_integration_example/README.md#using-a-cronjob-and-send-report-by-email
-->

<!--
I can not use helm.registry.coulombel.site
https://github.com/scoulomb/github-page-helm-deployer/blob/master/README.md#usage-of-helm-registry-once-helm-deliverable-are-pushed

scoulomb.github.io redirect to coulombel.site
https://github.com/scoulomb/github-page-helm-deployer/blob/master/appendix-github-page-and-dns.md#Blocking
-->


