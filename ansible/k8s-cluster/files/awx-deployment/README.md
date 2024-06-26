# AWX installation on k8s
This will install AWX on k8s cluster, run in the following order:

1. Install AWX operator
```
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm repo update
helm install ansible-awx-operator awx-operator/awx-operator -n awx --create-namespace
```
2. Create Persisten Volumves for postgres 
`kubectl create -f volumes.yml`

3. Deploy AWX
`kubectl apply -f ansible-awx.yml`

... wait and watch:
`watch kubectl get pods -n awx`

You should see result in few minutes similar to this:
```
$ kubectl get pods -n awx
NAME                                               READY   STATUS    RESTARTS   AGE
awx-operator-controller-manager-6569d67f4c-msb8d   2/2     Running   0          40m
awx-postgres-13-0                                  1/1     Running   0          14m
awx-task-f69557899-fhxcs                           4/4     Running   0          13m
awx-web-8485fb9757-vfnz5                           3/3     Running   0          11m
```

AWX is setup, get admin password with bellow command. Proceed to step 4 and 5 for setting up nginx load
balancer (recommended), or alternatively to step 3.1 for accessing AWX directly.

```
$ kubectl get secrets -n awx | grep -i admin-password
awx-admin-password                           Opaque               1      127m

$ kubectl get secret awx-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
xxxxxxxxxxxxxxxxxxxxx
```

3.1. If you do not want to use ingress-nginx then do this optional step, otherwise skip and go to 4. and 5.

Expose the web service so that we can access it from outside
```
kubectl expose deployment awx-web --name awx-web-svc --type NodePort -n awx
kubectl edit svc awx-web-svc -n awx
```

Add below two lines added UDNER `spec:`
```
spec:
  externalIPs:
  - 192.168.1.96
```

Get service port:
```
$ kubectl get svc -n awx
NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP      PORT(S)          AGE
awx-operator-controller-manager-metrics-service   ClusterIP   10.106.190.120   <none>           8443/TCP         141m
awx-postgres-13                                   ClusterIP   None             <none>           5432/TCP         116m
awx-service                                       NodePort    10.96.29.32      <none>           80:31407/TCP     115m
awx-web-svc                                       NodePort    10.110.190.217   192.168.1.96     8052:32541/TCP   4m51s
```

You should now be able to browse AWX web http://192.168.1.96:32451

4. Install nginx ingress and update its public IP
```
$ helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace
$ kubectl -n ingress-nginx get svc
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.101.20.76   <pending>     80:31459/TCP,443:31169/TCP   69s
ingress-nginx-controller-admission   ClusterIP      10.110.74.40   <none>        443/TCP                      69s
```
To fix `EXTERNAL-IP <pending>`, edit svc and add node's (i.e. kube-24) external IP (i.e. 192.168.1.96)
```
kubectl edit svc ingress-nginx-controller -n ingress-nginx
```
example edited config, below two lines added UDNER `spec:`
```
spec:
  externalIPs:
  - 192.168.1.96
```
Doc: https://kubernetes.github.io/ingress-nginx/deploy/baremetal/

5. nginx-ingress load balancer and TLS termination
Store TLS cert/key in k8s secret:
```
kubectl create secret tls awx-tls-selfsigned --cert=/tmp/cert.pem --key=/tmp/key.pem -n awx
```

Apply ingress manifest

```
kubectl apply -f ingress.yml
```

If you are getting this error:
```
Error from server (InternalError): error when creating "ingress.yml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": failed to call webhook: Post "https://ingress-nginx-controller-admission.ingress-nginx.svc:443/networking/v1/ingresses?timeout=10s": Unable to connect
```

Try this fix:
```
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
```


## Docs
- https://www.linuxtechi.com/install-ansible-awx-on-kubernetes-cluster/
- https://kubernetes.github.io/ingress-nginx/deploy/
- https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
