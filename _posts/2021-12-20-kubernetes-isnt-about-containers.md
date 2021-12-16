---
layout: post
title: Kubernetes isn't about containers
date: 2021-12-16 14:00:00 -0500
tags: containers kubernetes apis infrastructure
---

It's about APIs; we'll get to that shortly.

## First there were containers

Now Docker _is_ about containers: running complex software with a simple `docker run postgres` command was a revelation to software developers in 2013, unlocking agile infrastructure that they'd never known. And happily, as developers adopted containers as a standard build and run target, the industry realized that the same encapsulation fits nicely for workloads to be scheduled in compute clusters by orchestrators like Kubernetes and Apache Mesos. Containers have become the most important workload type managed by these schedulers, but as the title says that's not what's most valuable about Kubernetes.

Kubernetes is not about more general workload [scheduling][] either (sorry [Krustlet][] fans). While scheduling various workloads efficiently is an important value Kubernetes provides, it's not the reason for its success.

## Then there were APIs

<img width="400" alt="Always has been APIs" src="/assets/always_has_been_apis.jpeg" />

Rather, the attribute of Kubernetes that's made it so successful and valuable is that **it provides a set of standard programming interfaces for writing and using software-defined infrastructure services**. Kubernetes provides specifications and implementations - a complete framework - for designing, implementing, operating and using infrastructure services of all shapes and sizes based on the same core structures and semantics: typed resources watched and reconciled by controllers.

To elaborate, consider what preceded Kubernetes: a hodge-podge of hosted "cloud" services with different APIs, descriptor formats, and semantic patterns. We'd piece together compute instances, block storage, virtual networks and object stores in one cloud; and in another we'd create the same using entirely different structures and APIs. Tools like Terraform came along and offered a common format across providers, but the original structures and semantics remained as variegated as ever - a Terraform descriptor targeting AWS stands no chance in Azure!

Now consider what Kubernetes provided from its earliest releases: standard APIs for describing compute requirements as pods and containers; virtual networking as services and eventually ingresses; persistent storage as volumes; and even workload identities as attestable service accounts. These formats and APIs work smoothly within Kubernetes distributions running everywhere, from public clouds to private datacenters. Internally, each provider maps the Kubernetes structures and semantics to that hodge-podge of native APIs mentioned in the previous paragraph.

Kubernetes offers a standard interface for managing software-defined infrastructure - [cloud](https://joshgav.github.io/2021/09/30/cloud-redefined-infrastructure.html), in other words. **Kubernetes is a standard API framework for cloud services.**

## And then there were more APIs

Providing a fixed set of standard structures and semantics is the foundation of Kubernetes' success. Following on this, its next act is to extend that structure to _any and all_ infrastructure resources. [Custom Resource Definitions][] (CRDs) were introduced in version 1.7 to allow other types of services to reuse Kubernetes' programming framework. CRDs make it possible to request not only predefined compute, storage and network services from the Kubernetes API, but also databases, task runners, message buses, digital certificates, and whatever else a provider can imagine!

As providers have sought to offer their services via the Kubernetes API as custom resources, the [Operator Framework][] and related projects from [SIG API Machinery][] have emerged to provide tools and guidance that minimize work required and maximize standardization across all these shiny new resource types. Projects like [Crossplane][] have formed to map other provider resources like RDS databases and SQS queues into the Kubernetes API just like network interfaces and disks are handled by core Kubernetes controllers today. And Kubernetes distributors like [Google](https://cloud.google.com/blog/topics/developers-practitioners/build-platform-krm-part-2-how-kubernetes-resource-model-works) and [Red Hat](https://docs.openshift.com/container-platform/4.9/operators/understanding/crds/crd-managing-resources-from-crds.html) are providing more and more custom resource types in their base Kubernetes distributions.

All of this isn't to say that the Kubernetes API framework is perfect. Rather it's to say that _it doesn't matter_ (much) because the Kubernetes model has become a de facto standard. Many developers understand it, many tools speak it, and many providers use it. Even with warts, Kubernetes' broad adoption, user awareness and interoperability mostly outweigh other considerations.

With the spread of the Kubernetes resource model it's already possible to describe an entire software-defined computing environment as a collection of Kubernetes resources. Like running a single artifact with `docker run ...`, distributed applications can be deployed and run with a simple `kubectl apply -f ...`. And unlike the custom formats and tools offered by individual cloud service providers, the Kubernetes' descriptors are much more likely to run in many different provider and datacenter environments, because **they all implement the same APIs**.

Kubernetes isn't about containers after all. It's about APIs.

[scheduling]: <https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/>
[krustlet]: <https://krustlet.dev/>
[Custom Resource Definitions]: <https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/>
[Operator Framework]: <https://operatorframework.io/>
[SIG API Machinery]: <https://github.com/kubernetes/community/tree/master/sig-api-machinery>
[Crossplane]: <https://crossplane.io>