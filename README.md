# To install consul Connect with consul-helm:

This is a demonstration on how to get connect-inject working with the helm chart consul-helm.  This is not a generic demo of how to use consul-helm, and we mostly assume that you have already run and understand consul-helm.

## Prerequisites

- helm installed on this machine and tiller installed.  
- kubectl configured and pointed to the k8s cluster you want to test with.
- This will work on osx and linux as is, on a windows client just examine any of the simple scripts and run the appropriate commands.
- I have only tested this with a 3 node cloud based k8s cluster.  I've tested with AKS and will soon test AWS.  I do not know how this performs on minikube, this is probably something that doesn't translate well to minikube.
- The consul-helm requests 10gb storage on each server node by default.  You will need to have sufficient storages on your nodes.


## Running It
First clone the demonstration code and consul-helm
```bash
git clone git@github.com:stvdilln/consul-inject-demo.git
cd consul-inject 
./clone-consul-helm
```
This demonstration has a version of values.yaml.  In the included copy of values.yaml the following fields were changed.
- global.bootstrapACLS: true
- global.grpc: true
- ui.service.type: LoadBalancer  
- connectInject.enabled: true


## Security Warning
My changes enable a loadbalancer on the Consul UI. Depending on your cloud provider this may be exposed to the public.  When the load balancer completes, please verify that it is not running on a public IP address.  I have added annotations to try and prevent that. ACLs are enabled in the config, but you still don't want your consul-ui exposed to the world.  


We now will intall the consul components with helm.  This command assumes the kubectl is configured to correct cluster.  You will need helm installed on your machine and the K8s cluster (helm init).
```bash
   helm install --name consul -f values.yaml ./consul-helm 
```



Wait for the dust to settle, you should have 3 server consul pods, and 3 clients.   The load balancer for the UI can take awhile `kubectl get service` and see when the load balancer completes.  It is best to have the UI working so that you can see the 
services you are creating.  Since ACLs are enabled, the UI will show only minimal information.  To 'login' to the UI you need a token, which there are several stored in the kubernetes secrets.  This command will get the master token which is not best practice for logging into the UI except for a quick demostration.  



```
 kubectl get secret consul-consul-bootstrap-acl-token -o json | jq -r '.data.token' | base64 -D
```
In the UI navigate to the ACL page and paste the GUID you just retreived.  Your UI should show you more items now.

## Starting the demontration server

```kubectl apply -f demo-server.yaml```

When you run that command you should see new services appear on the UI services page.  "demo-helloworld" and "demo-helloworld-sidecar-proxy".  The demo-helloworld is your container, and the proxy is the container that consul-inject added as the pod was created.  You can examine what consul-inject did to the demo-server.yaml with `kubectl get pods` and  `kubectl describe pod consul-inject-demo-server-{xxxxxx-yyyyy}`.

### Start the Client
```kubectl apply -f demo-client.yaml```

This will create a pod demo-client, that you can open a shell into:
`kubectl exec -it demo-client -- bash`

Poking around in the above shell.  `netstat -nltp` shows 3 ports, port 20000 is inbound envoy traffic to the consul-connect sidecar, port 19000 is another envoy port.  Port 1234 is the port that we opened as a tunnel to our serivce.  Look at the demo-client.yaml and demo-server.yaml for the annotations that creates this port.  Before we test out the connection we 
need to authorize the connection in consul.  In the UI -> Intentions -> Create
- source service: demo-client
- Destination Service: demo-helloworld
- Allow

If you do not want to use the GUI, you can create the consul
debug container below and run these CLIs to create the intent.
```
stevedi$ k exec -it consul-debug-container -- sh
/ # consul catalog services
consul
demo-client
demo-client-sidecar-proxy
demo-helloworld
demo-helloworld-sidecar-proxy
/ # consul intention create -allow demo-client demo-helloworld
Created: demo-client => demo-helloworld (allow)
``` 

Once you have set the intentions you can execute `curl http://localhost:1234/` in the client shell and should retreive a web page.  There are also environment variables you can use for the service name and port.

### Bonus
I have created a container `kubectl apply -f consul-debug-container` which will launch a consul client with appropriate acls to access the consul cluster.  You can:
```
stevedi_mac2:consul-inject-demo stevedi$ k exec -it consul-debug-container -- sh
/ # consul catalog services
consul
demo-helloworld
demo-helloworld-sidecar-proxy
static-client
static-client-sidecar-proxy
```