# Project presentation

## Links between projects overview
 
- Seed: https://github.com/scoulomb/soapui-docker
    - Which is pointing to: https://github.com/scoulomb/soapui-docker/blob/master/kubernetes_integration_example/README.md (this page has no dev guide, it is a dev tuto)
        - Which is pointing to: https://github.com/scoulomb/mail-sender
        - And to: https://github.com/scoulomb/github-page-helm-deployer
          - which is pointing to  https://github.com/scoulomb/myk8s  
          - And to https://github.com/scoulomb/mydns 

<!--
- private repo contains what is private in this repo (private)
--> 

## Presentation 

- Follow the README starting from [README](./README.md) and just show replacement with team non reg in compose. (skip dev guide)
Insist on the curl in [kubernetes_integration_example](./kubernetes_integration_example/Dockerfile)
- Follow mail sender
- And then deployer

## Alternative and perspective

<!--
adaptation link [private.md](./private.md)
-->

- Try to deploy Jenkins in k8s (but not serverless) or dokcerize mvn non reg

==> Jenkins

https://hub.helm.sh/charts/bitnami/jenkins

````
sudo minikube start --vm-driver=none
sudo su 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/jenkins
helm uninstall my-release
````

We need to define a volume (`k get pvc`) indicates we should have a persistent volume like before
Doc: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

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

If image pull back off, `sudo systemd-resolve --flush-caches` (vpn)

<!--
I can not deploy because of space issue.
-->

- Also Parallel with Karate4nw


<!--
image pull at every job  + what about backoff
SO question

JM stops: https://github.com/scoulomb/soapui-docker/blob/master/kubernetes_integration_example/README.md#using-a-cronjob-and-send-report-by-email

-->

See private.md with findings