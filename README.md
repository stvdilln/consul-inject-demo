# To install consul Connect with consul-helm:

This is a demonstration on how to get connect-inject working with the helm chart consul-helm.  This is not a generic demo of how to use consul-helm, and we mostly assume that you have already run and understand consul-helm.

## Prerequisites

- helm installed on this machine and tiller installed.  
- kubectl configured and pointed to the k8s cluster you want to test with.
- This will work on osx and linux as is, on a windows client just examine any of the simple scripts and run the appropriate commands.
- I have only tested this with a 3 node cloud based k8s cluster.  I've tested with AKS and will soon test AWS.  I do not know how this performs on minikube, this is probably something that doesn't translate well to minikube.
- The consul-helm requests 10gb storage on each server node by default.  You will need to have sufficient storages on your nodes.

I have transfered the narative over to a [Blog on Medium.com](https://medium.com/@stvdilln/using-consul-helm-to-create-mtls-infrastructure-6de621f1fbb4)