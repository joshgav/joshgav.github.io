---
layout: post
title: Orchestrate platforms with Kubernetes
date: 2023-10-14 17:00:00 -0500
tags: kubernetes platforms operators
slug: orchestrate-platforms-with-kubernetes
---

<img width=600 alt="well-orchestrated" src="../assets/well-orchestrated.png" />

Sometimes an obvious idea still deserves to be stated explicitly. One such idea
is that the Kubernetes API and its ever-growing ecosystem of extensions and
extensibility frameworks is an ideal open, portable orchestrator for today's
emerging internal enterprise developer platforms. In this post I'll explain why
that is and what it means to adopt Kubernetes as orchestrator.

To set the stage, our industry is currently intrigued by the value of internal
cloud-like platforms that provision and manage high-level capabilities for
products and applications on demand. The term "orchestrator" is often used to
describe the central "brain" of these platforms; such an _orchestrator_ is a set
of controllers that calculate and execute workflows as required to manage
high-level capabilities and components for applications and maintain those
capabilities in their expected, desired state.

Let's reflect further on what orchestrators are. In fact the term has been used
for a while to describe resource managers like Azure Resource Manager (ARM),
Hashicorp Terraform and even AlibabaCloud's [Resource Orchestration
Service](https://www.alibabacloud.com/product/ros); as well as Linux container
managers like Apache Mesos, Docker Swarm and even our beloved Kubernetes. What
is common to all these? The aspect they share is that they receive workload
descriptors and resource requests centrally then coordinate and route those
requests to be fulfilled by many other resource and service providers. That is,
orchestrators coordinate request fulfillment across many service providers.

For example, submit a collection of resources to Azure's Resource Manager and it
in turn will call a Storage resource provider (RP), a Database RP, and many
other Azure and third-party RPs to complete your request. Apply a collection of
resources via `terraform apply` and it uses some of its many providers to
provision those resources. Or last but not least, submit a bunch of Kubernetes
resources to a Kubernetes API server and it will delegate them to its many
built-in and custom controllers to manage.

## Kubernetes is an orchestrator

As I've mentioned in [other posts](https://blog.joshgav.com/posts/kubernetes-isnt-about-containers),
Kubernetes emerged as a way to coordinate and run containers across many Linux
machines, but the real value of Kubernetes is that it's a de facto open,
portable, standard API framework for software-defined - aka cloud - infrastructure;
that is, Kubernetes is a framework for automatable infrastructure and platform
capability management. Because Kubernetes offers this we can and should use it
as a framework for building platform orchestrators.

That's the central idea here so let me repeat it: **we can and should use the
Kubernetes API as a framework for building platform orchestrators.**

Why? First, Kubernetes and its patterns and tools is an open standard for
infrastructure and platform management. Perhaps it took us a while to get
comfortable with it but at this point Kubernetes is familiar to most experienced
industry practitioners, and tools and practices like kubectl and GitOps are
broadly understood. It's a completely open standard too - its source is licensed
openly and managed by a foundation, new specs are developed openly with input
from many companies and individuals, and managed implementations that conform to
those specs and standards are available from many providers. So building on
Kubernetes is a reliable investment.

Next, a vast array of open source projects are embracing the pattern of
orchestrating their own published capabilities and internal components via
Kubernetes controllers. Almost all CNCF projects are installed by deploying
controllers in Kubernetes clusters; and then used by declaring those
controllers' resources via Custom Resources (from "CRDs"). So it's natural for companies seeking to build their own thinnest
viable platforms on the shoulders of open upstream projects to adopt Kubernetes
too.

Last, and far from least, a number of frameworks are now available that make
building an orchestrator (aka a "control plane" or "internal platform") on
Kubernetes straightforward. Platform engineers don't have to rewrite or even
recompile Kubernetes to extend it, they simply need to learn and leverage
Operator Framework, Crossplane, KUDO, Kratix or tomorrow's newest controller
management framework.

The ubiquity and openness of Kubernetes and its ecosystem are key reasons it
should be your first choice as a platform orchestrator.

## What does that mean?

So what does it look like to use Kubernetes as your platform orchestrator? Let's
start with the following graphic:

<img width=600 alt="Kubernetes-based Platform" src="../assets/k8s-plat.png" />

First, let's again define a platform orchestrator: a system that executes
workflows to provision and/or maintain platform capabilities and
software-defined infrastructure. Kubernetes acts like an orchestrator and runs
such workflows when triggered by resources submitted to its API server: once
admitted, Kubernetes controllers discover new and changed resources for types
under their management and execute tasks to bring those resources to their
declared desired state.

For example, if a `Deployment` resource is submitted to Kubernetes, a Deployment
controller ensures one pod template per desired replica is rendered and
instantiated in the cluster. If an `Ingress` resource is submitted, a network
controller ensures routing tables in nodes and cloud services are configured to
route traffic as desired.

But as we mentioned above, Kubernetes can handle much more than its built-in
resources like Pods, Services and Volumes. For example, today's broad collection
of CNCF projects offer themselves primarily as extension controllers to
Kubernetes too.  Want a virtual machine instead of a container? There's a
controller - KubeVirt - and custom resource for that. Want a certificate
management system?  Try cert-manager. Looking for Kafka infrastructure? Try
Strimzi. Need a directory and OpenIDConnect system? Choose from Dex or Keycloak.

And Kubernetes' usefulness as a general orchestrator and control plane doesn't
stop with cluster-internal resource types. Using the likes of [AWS Controllers
for Kubernetes](https://aws-controllers-k8s.github.io/community/), [Azure
Service Operator](https://azure.github.io/azure-service-operator/), and [Google
Cloud Config
Connector](https://cloud.google.com/config-connector/docs/overview), internal
platforms can offer to provision and manage provider-managed services using the
same paradigms as internal, in-cluster resources.

## What does that mean _to you_?

The previous section describes the robust collection of pieces and building
blocks available today for building a platform orchestrator on Kubernetes.
Indeed some intrepid organizations are already building platforms and
orchestrators from this hodgepodge of pieces - installing each controller in its
own way while gradually establishing common standards and patterns. These
systems often include and are even sometimes equated with Kubernetes-native
delivery systems that accompany them like GitOps via ArgoCD or Flux.

But the truth is another component is needed to consistently coordinate the
collection of controllers in Kubernetes that make it a complete platform; and
several frameworks are emerging and maturing to enable this - find them in the
above graphic as part of Kubernetes' "extended" control plane. The first and
perhaps still most popular controller manager is Red Hat's [Operator
Framework](https://operatorframework.io/), which provides not only tools to
curate and create new controllers but also a "contoller of controllers" known as
[Operator Lifecycle Manager](https://olm.operatorframework.io/) to package and
deploy controllers into clusters and keep them up to date.

Another popular controller manager framework is Upbound's
[Crossplane](https://crossplane.io/). Crossplane includes a system for managing
extension controllers - known in Crossplane as providers - as well as a
higher-level type composition system known as "composite resource definitions"
("XRDs") to work with new resource types from those providers. Other frameworks
for managing a collection of Kubernetes controllers are
[Kratix](https:/kratix.io/), [KUDO](https://kudo.dev/) and
[KubeVela](https://kubevela.io/). Notably, each of these frameworks also offers
a catalog of compatible extensions, many of which are also listed in CNCF's
syndicated [ArtifactHub](https://artifacthub.io/). The primary catalogs for each
framework can be found in the following table.

Framework   | Catalog
------------|--------
[Operator Framework](https://operatorframework.io/) | [Operator Hub](https://operatorhub.io/)
[Crossplane](https://www.crossplane.io/) | [Upbound Marketplace](https://marketplace.upbound.io/)
[Kratix](https://kratix.io/) | [Kratix Marketpace](https://kratix.io/marketplace)
[KUDO](https://kudo.dev/) | [KUDO Operators](https://github.com/kudobuilder/operators/)
[KubeVela](https://kubevela.io/) | [KubeVela Catalog](https://github.com/kubevela/catalog)

The point of this section is to emphasize that if you already do or plan to use
Kubernetes as an orchestrator you should strongly consider choosing a framework
to help build and manage all those Kubernetes extensions and controllers
consistently. Some forward-thinking organizations may have started building such
a framework themselves, gathering standards and templates for installing Helm
charts, running scripts and implementing other practices for deploying and
managing controllers. Whether you've already built something yourself or not, if
you're building a platform on Kubernetes I recommend evaluating, adopting and
helping evolve one of the open source frameworks mentioned above for all of our
benefit.

## Now what?

In conclusion, Kubernetes stands waiting as a de facto open, standard, hybrid
orchestrator for your internal platforms. Choose a controller manager framework,
choose some capabilities and start building your platform on Kubernetes today!
