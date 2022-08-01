---
layout: post
title: Run OpenShift on AWS
date: 2022-08-09 02:00:00 -0500
tags: clusters openshift
---

OpenShift is a Kubernetes distribution with batteries included - it's ready for
many use cases out of the box. For example, a default installation includes a
network provider (CNI), container builder and registry, external ingress
provider and a cluster lifecycle management system. Contrast this with a cluster
provisioned by
[kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
or even the more featureful
[kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/),
where adding these and other critical features requires thoughtful and often
fragile integration.

Not only does OpenShift offer a turnkey, ready-to-use Kubernetes environment, it
also has become easier and easier to deploy over time. Gone are the days when
operators and infrastructure teams would have to pre-provision Linux nodes and
carefully configure cloud networks. Though it's still possible to customize to
your (or your organization's!) heart's content, many use cases can be met with
just a few commands to spin up an OpenShift Kubernetes cluster on a public cloud
provider like Amazon Web Services.

In this article we'll discuss three ways to deploy and run OpenShift on AWS,
then we'll contrast these with deploying upstream Kubernetes with kubespray.
Follow along with the code at https://github.com/joshgav/openshift-on-aws.git.

## ROSA: Red Hat OpenShift Service on AWS

Follow along with [the scripts](https://github.com/joshgav/openshift-on-aws/tree/main/rosa).

Let's start with the simplest option: Red Hat OpenShift Service on AWS, ROSA.
Deployment of a ROSA cluster includes deployment and correct configuration of
required compute, network and storage resources in AWS EC2 in addition to a
fully-featured OpenShift Kubernetes cluster. As opposed to other options to be
discussed, a ROSA environment is fully supported by Red Hat's operations teams -
open a ticket and an expert Red Hat SRE will attend to it quickly.

### Setup

At the core of the ROSA lifecycle is the [rosa
CLI](https://docs.openshift.com/rosa/rosa_cli/rosa-get-started-cli.html). Get it
from the [Downloads](https://console.redhat.com/openshift/downloads) section of
the Red Hat Console or directly from
<https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz>.

You'll need both Red Hat and AWS credentials to enable the `rosa` CLI to
provision and connect to resources. Your AWS credentials can be specified as
exported `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION`
environment variables as [for the AWS
CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

To get a token to login to your Red Hat account, click "View API token" at the
bottom of the Downloads page as shown in the following screenshot, or go
straight to [the token page](https://console.redhat.com/openshift/token). On
that page click "Load token", then copy the raw token (not the `ocm` command
line) and run `rosa login --token="${your_token}"`. If successful you will see
this message (with your username of course): "I: Logged in as 'joshgavant' on
'https://api.openshift.com'.

<img src="../assets/openshift_on_aws/console-downloads-token.png" width="300px" />
<img src="../assets/openshift_on_aws/ocm-manage-token.png" width="300px" />

> Tip: To quickly enable autocompletion for `rosa` commands in your current
  shell session run `. <(rosa completion)`.

To verify that you've logged in successfully to both accounts run `rosa whoami`.

### IAM Roles

Next you'll need to create an AWS IAM role specifying the permissions Red Hat's
cluster manager service and operations team members will require. In STS mode,
these roles will be applied to the short-lived tokens issued to these operators
on demand. Run the following commands to create the OCM service role and the
operator user role:

```bash
rosa create --yes ocm-role --admin --mode=auto --prefix="ManagedOpenShift"
rosa create --yes user-role --mode=auto --prefix="ManagedOpenShift"
rosa create --yes account-roles --mode=auto --prefix="ManagedOpenShift"
```

### Create cluster

Now that you've bound your Red Hat account with your AWS account you can proceed
to create your ROSA cluster! If you'd like to use the rosa CLI, run the
following command to create a cluster in [STS
mode](https://docs.openshift.com/rosa/rosa_getting_started/rosa-sts-getting-started-workflow.html).

Note that by setting the `--watch` flag installation logs will stream to stdout
and the command won't return till installation completes successfully or fails,
typically >30 minutes. You can not set set that flag, or exit the log stream
with Ctrl+c, then watch logs again with `rosa logs install --cluster ${CLUSTER_NAME} --watch`.

```bash
## create a ROSA cluster in STS mode
rosa create --yes cluster --cluster-name "${CLUSTER_NAME}" --sts --mode=auto --watch
```

### Monitor installation

Note that by setting the `--watch` flag installation logs will stream to stdout
and the command won't return till installation completes successfully or fails,
typically >30 minutes. You can not set set that flag, or exit the log stream
with Ctrl+c, then watch logs again with `rosa logs install --cluster ${CLUSTER_NAME} --watch`.

You can also see your new cluster in the [Red Hat
Console](https://console.redhat.com/openshift). Click into it and expand the
"Show logs" section to reach a view like the following:

<img src="../assets/openshift_on_aws/view-cluster-webui.png" width="300px" />

### Use cluster

Once it's ready, the easiest way to begin using your cluster immediately is to
create a one-off `cluster-admin` user as follows. Later you can allow users from
a specific OpenIDConnect (OIDC) identity provider.

```bash
## create a cluster-admin user
rosa create --yes admin --cluster "${CLUSTER_NAME}"
```

Next, you'll need URLs to reach the API server and Console of your new cluster!
Get those with `rosa list clusters`. Finally, log in to the cluster via the `oc`
CLI: `oc login --user cluster-admin --password ${admin_password}`.

### Create cluster via UI

Note that once your Red Hat and AWS accounts are linked you can also choose to
create a cluster via a guided wizard in the Console. On the [Clusters
page](https://console.redhat.com/openshift) on the Red Hat Console click "Create
cluster", then on the [Cluster create
page](https://console.redhat.com/openshift/create) click "Create cluster" next
to the ROSA offering, as in the following screenshot:

<img src="../assets/openshift_on_aws/create-cluster-webui.png" width="300px" />

If you've properly associated your accounts then your AWS account will be listed
(by its ID) on the first page of the wizard. Follow the prompts to configure and
install a cluster.

## Installer-provisioned infrastructure (IPI)

Follow along with [the scripts](https://github.com/joshgav/openshift-on-aws/tree/main/ipi).

Even if your cluster won't be managed by Red Hat you can provision and configure
cloud infrastructure and the cluster itself in AWS with a similar short list of
commands. Red Hat calls this installation method "Installer-provisioned
infrastructure" (IPI). Here's how to do it.

### Setup

The core of the IPI method is the **`openshift-install`** CLI; download it from
the [downloads section](https://console.redhat.com/openshift/downloads#tool-x86_64-openshift-install)
of the OpenShift console, or directly from
<https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-install-linux.tar.gz>.

You'll also need a **pull secret** containing credentials for Red Hat's
container registries. Copy this from
<https://console.redhat.com/openshift/downloads#tool-pull-secret>.

A **SSH key pair** is required for access to provisioned machines; you'll need
to provide its public key to the installer and you'll be able to use the private
key for access. You can copy an existing key from (for example)
`~/.ssh/id_rsa.pub`; or create a new one in a secure place using (for example)
`ssh-keygen -t rsa -b 4096 -C "user@openshift" -f "${WORKDIR}/id_rsa" -N ''`.
Copy the contents of the `*.pub` file as the value of `SSH_PUBLIC_KEY` below.

Finally, you'll need an AWS **Route53 public hosted zone** for your cluster's
base domain name. For example, I delegate a domain named `aws.joshgav.com` from
my registrar to a new AWS Route53 zone, see following screenshot. Specifically,
after creating the Route53 zone I create NS records for `aws` in the parent
`joshgav.com` zone pointing to the name servers selected by Route53. More
details [from RedHat
here](https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-account.html#installation-aws-route53_installing-aws-account)
and [from AWS
here](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html).

<img src="../assets/openshift_on_aws/aws-route53.png" width="300px" />

### Create cluster

Now you can use `openshift-install create ...` to independently manage various
phases of the installation process. A simple, automatable approach is to define
the desired state of your cluster in a file named `install-config.yaml` put it
in a directory `${WORKDIR}` and run the installer with it as follows:
`openshift-install create cluster --dir ${WORKDIR}`. Following is a template
install-config.yaml file; use it with your own values for
`OPENSHIFT_PULL_SECRET`, `YOUR_DOMAIN_NAME` and `SSH_PUBLIC_KEY` established
above.

> NOTE: The schema for install-config is in <https://github.com/openshift/installer/blob/master/pkg/types/installconfig.go>.

```yaml
apiVersion: v1
metadata:
  name: ipi
baseDomain: ${YOUR_DOMAIN_NAME}
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
networking:
  networkType: OVNKubernetes
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: us-east-1
publish: External
pullSecret: '${OPENSHIFT_PULL_SECRET}'
sshKey: '${SSH_PUBLIC_KEY}'
```

### Monitor installation

Cluster installation will take 30 minutes or more. You can watch logs stream to
stdout or tail the .openshift_install.log file in the installation working
directory.

### Use cluster

A username and password for your cluster will be in the final lines of the log,
either on stdout or in the `.openshift_install.log` file. In addition, a
"kubeconfig" file and the kubeadmin user's password are saved in the `auth`
directory of the installation dir. Login to your cluster with one of the
following:

```bash
## using kubeconfig with embedded certificate
export KUBECONFIG=temp/_workdir/auth/kubeconfig

## using username and password
oc login --user kubeadmin --password "$(cat temp/_workdir/auth/kubeadmin-password)"

## verify authorization
oc get pods -A
```

## User-provisioned infrastructure (UPI)

Follow along with [the scripts](https://github.com/joshgav/openshift-on-aws/tree/main/upi).

Though the easiest way to get started with OpenShift on AWS is via ROSA or
installer-provisioned infrastructure (IPI), Red Hat also allows you to deploy
and configure your own cloud infrastructure - machines, networks and storage -
and provision a cluster over it. This is known as "user-provisioned
infrastructure" - UPI.

UPI installations still use the `openshift-install` CLI to generate resource
manifests and Ignition configuration files. However it is up to the user to
configure machines and supply these Ignition files to them. In AWS this is
accomplished by putting a configuration in a S3 bucket and pointing the first
machine there at startup.

Red Hat provides a set of CloudFormation templates reflecting good patterns for
provisioning supporting infrastructure for an OpenShift cluster; these templates
are available
[here](https://github.com/openshift/installer/tree/master/upi/aws/cloudformation).
In the `upi` directory in the repo which accomplanies this article a `deploy.sh`
script steps through the following:

1. Create manifests and configurations with `openshift-install`
1. Deploy AWS networks and machines using recommended CloudFormation templates
1. Await completed installation using `openshift-install`

The AWS resources created for OpenShift include a VPC and subnets, a DNS zone
and records, load balancers and target groups, IAM roles, security groups and
even an S3 bucket. They also include several machine types - bootstrap, control
plane and worker. The bootstrap machine is provisioned first and installs the
production cluster on the other machines.

Full instructions for AWS UPI are [here](https://docs.openshift.com/container-platform/4.10/installing/installing_aws/installing-aws-user-infra.html).

Note that one step in the process can be difficult to automate - signing
Certificate Signing Requests (CSRs) for nodes. Check if CSRs are awaiting a
signature with `oc get csr`. Approve all pending requests with the following:

```bash
csrs=($(oc get csr -o json | jq -r '.items[] | select(.status == {}) | .metadata.name'))
for csr in "${csrs[@]}"; do
    oc adm certificate approve "${csr}"
done
```

As with IPI, you can monitor the `.openshift_install.log` file for progress of
cluster installation. When the cluster is ready, log in with `oc login` as the
kubeadmin user with the password in `${workdir}/auth/kubeadmin-password`, or set
your KUBECONFIG env var to the path `${workdir}/auth/kubeconfig`.

Once ready reach the console of your cluster at
`https://console-openshift-console.apps.${CLUSTER_NAME}.${BASE_DOMAIN}/`.

## Kubespray

Follow along with [the scripts](https://github.com/joshgav/openshift-on-aws/tree/main/kubespray).

The previous sections described how to deploy OpenShift, Red Hat's Kubernetes
distribution, on Amazon Web Services with various levels of support and
automation. Next we'll deploy upstream Kubernetes using
[Kubespray](https://kubespray.io) in order to compare, contrast and gather new
ideas. Notably, kubespray's included configuration for AWS infrastructure yields
an environment nearly identical to that produced by openshift-install.

> Note: The most basic cluster installation tool is [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/), but it leaves
many critical aspects of the cluster incomplete, such as a network overlay,
container registry and load balancer controller. [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/) is also
maintained by the Kubernetes project and provides a more complete deployment.

As with user-provisioned infrastructure (UPI) for OpenShift, with Kubespray the
user must first install infrastructure, then use Kubespray to install a cluster
on that infrastructure. Kubespray offers Terraform configurations for deploying
typical environments in cloud providers. For this example I used the
[configurations for
AWS](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform/aws)
which yields the following env:

<img src="../assets/openshift_on_aws/aws-kubespray.png" width="300px" />

> From <https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/terraform/aws/docs/aws_kubespray.png>

The infrastructure provisioning process finishes by creating an inventory file
which Ansible will consume to deploy cluster components. Now you'll run the main
Kubespray process - an Ansible playbook - using that inventory:
`ansible-playbook -i hosts.ini cluster.yaml`. You can customize the deployment
by setting variables in the inventory vars files or by passing `-e key=value`
pairs to the ansible-playbook invocation. See `deploy-cluster.sh` in the
walkthrough for examples. So that you don't have to install the Kubespray
Ansible environment locally, you may prefer to run commands like the following
in a container:

```bash
podman run --rm -it \
    --mount type=bind,source=kubespray/inventory/cluster,dst=/inventory,relabel=shared \
    --mount type=bind,source=.ssh/id_rsa,dst=/root/.ssh/id_rsa,relabel=shared \
        quay.io/kubespray/kubespray:v2.19.0 \
            bash

# when prompted, enter (for example):
ansible-playbook cluster.yml \
    -i /inventory/hosts.ini \
    --private-key /root/.ssh/id_rsa \
    --become --become-user=root \
    -e "kube_version=v1.23.7" \
    -e "ansible_user=ec2-user" \
    -e "kubeconfig_localhost=true"
```

By setting the variable `kubeconfig_localhost=true` a kubeconfig file with
credentials for the provisioned cluster will be written to the inventory
directory at the end of provisioning. It will use the internal IP address of an
API server; you'll need to change this to the address of your
externally-accessible load balancer. Retrieve that with `aws elbv2
describe-load-balancers --output json | jq -r '.LoadBalancers[0].DNSName'`, and
be sure to prepend `https://` and append `:6443/` when putting it in the file.
Finally set your KUBECONFIG env var to point to that file and run `kubectl get
pods -A` to verify connectivity.

## Conclusion

In this article and accompanying code we've discussed and demonstrated how to
deploy an OpenShift or upstream Kubernetes cluster in AWS using four different
methods which progress from simplest to most complex: ROSA > IPI > UPI >
Kubespray.

To minimize the complexity and overhead of managing your own clouds and
clusters, start with the simplest method - ROSA - and progress to others only as
greater control and customization is needed.

Please provide feedback in [the
repo](https://github.com/joshgav/openshift-on-aws/) or on
[Twitter](https://twitter.com/joshugav). Thank you!