# Kubernetes cluster setup

This role will prepare host for kubernetes. It can also init the control plane node.

### TODO
- join worker node
- maybe need DNS before setting up any k8s node.
(EOF)

## For the first control plane node.
Once ansible finishes the setup, you can init the cluster:
`sudo kubeadm init`

Then install cilium CNI:
https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli

Then you can install Helm, it can be used to install applications easily.
https://helm.sh/docs/intro/install/#from-script

Or you can instruct this ansible to do it automatically.

## Automatically init the control plane
If you want this role to init the cluster, then pass these
variables to the host:

`k8s_kubeadm_init: yes`

Additionally if you want to install Helm:

`k8s_install_helm: yes`

Either in host_vars or in ad-hoc cli, example:

```
ansible-playbook play-k8s-mgmt.yml -K -e k8s_kubeadm_init=yes -e k8s_install_helm=yes
```

When done, check output of "/root/kubeadm_init_output.txt".

## Further steps
This will only create one control plane instance. You can use it as standalone k8s server by
passing this command which will allow running apps on control plane node:

`kubectl taint nodes --all node-role.kubernetes.io/control-plane-`

or you can add more controler planes or worker nodes.

### Worker node
On the control plane node, run this command to create a join command:

`kubeadm token create --print-join-command`

then run this command on a worker node.

## Links
- manual steps https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- fix to apt gpg key: https://github.com/kubernetes/k8s.io/pull/4837#issuecomment-1446426585
