---
layout: post
title: Cloud redefines enterprise infrastructure
date: 2021-09-30 08:00:00 -0500
tags: platform infrastructure
---

![clouds](/assets/clouds.png)

Cloud computing has been around for well over a decade, so we ought to know what "cloud" is by now. Indeed we understand its attributes well, such as flexibility, efficiency, connectivity, and scalability; in the [words of the CNCF](https://github.com/cncf/toc/blob/main/DEFINITION.md) (emphasis added):

> Cloud native technologies empower organizations to build and run **scalable** applications in modern, **dynamic** environments...  These techniques enable loosely coupled systems that are **resilient**, **manageable**, and **observable**... They allow engineers to make high-impact changes **frequently** and predictably with minimal toil.

But what is "cloud" itself, provider of all these desirable attributes? Particularly in our era of hybrid, multi, and private "clouds" we should clearly define the term. And how does "cloud" relate to the rest of our infrastructure?

## What is cloud?

Let us describe "cloud" by induction from existing ones: a **cloud** is a collection of automatable _infrastructure services_ managed via a consistent set of interfaces - APIs, Web UIs, and CLIs. An **infrastructure service** is a service which serves other services which in turn serve users - an infrastructure service serves end users only indirectly. Stated a bit differently, **an infrastructure service serves applications** and their developers and **a cloud is a collection of such services**.

Per this definition, any provider of infrastructure services might be considered a cloud provider, though generally we reserve the title for providers that offer many diverse service types. "Multi-cloud" environments are those using infrastructure services from several providers. A "private cloud" is a collection of infrastructure services offered via an internal, perhaps custom interface.

With this in mind let's now describe how cloud is changing enterprise infrastructure.

### From servers to serverless

Before "cloud" many infrastructure specialists managed hardware servers, datacenters, network devices and operating system configurations. But "cloud" is replacing most such physical components with programmable, software-defined ones - virtual machines, virtual networks, dynamic datastores and queues, and much more. The job of infrastructure specialists is now to **program virtual infrastructure**.

A consistent, thorough, app-centric interface is one reasonable ultimate realization of cloud as defined, so "serverless" is a good example of a cloud interface for infrastructure driven strictly by app requirements. The most common paradigm though for programming virtual infrastructure today is to virtualize and automate existing architectural patterns - such as describing a router, a pod, and a datastore as software-defined Kubernetes resources and having a controller reify them.

Whatever the interface though, **infrastructure is not about hardware anymore, it's about software**.

### From services to platform

Another change is that before "cloud" infrastructure services were often offered by different teams via different interfaces. An identity or TLS certificate was issued by one team; another would provision a collector for logs and metrics; and another would deploy servers, networks and operating systems. Each would collect metadata and implement requirements from app teams in their own ways.

But as infrastructure services become software-defined, interfaces and processes for acquiring those services can become more consistent, easier and faster for apps and developers to use and manage. For example, a set of Kubernetes resources or Terraform manifests could describe every infrastructure service required by an application.

In other words, cloud is an opportunity to bring together a bunch of disparate services and interfaces into a consistent **platform**.

In graphic form, cloud takes us from:

![infra-current-state](/assets/infra_current_state.png)

#### to:

![infra-desired-state](/assets/infra_desired_state.png)

### From dependency to partner

As infrastructure becomes more flexible and more capable of quickly fulfilling app developers' needs, infrastructure teams are enabled to partner and agilely develop services together with application developers. The agility enabled by software allows infrastructure teams to deliver their set of services as a cohesive product to app developers, gathering and iterating quickly on feedback and new requirements.

With cloud, **infrastructure becomes an active partner to product teams in delivering business value** to customers and reacting to new circumstances.

## Conclusion

A "cloud" is _not_ just something run by big tech companies like Microsoft and Amazon. Rather, "cloud" is _the_ new paradigm of enterprise infrastructure itself: providing a consistent collection of automatable infrastructure services to apps and developers.

How are you providing "cloud" at your organization?
