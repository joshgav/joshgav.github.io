---
layout: post
title: Deliver platform capabilities
date: 2021-08-30 08:00:00 -0500
categories: platform infrastructure architecture
---

# Deliver platform capabilities

Platform teams exist to develop and manage capabilities required across many application service teams. When functioning well, platform teams provide expertise and support for complex capabilities which would otherwise have required such support in each application service team.

This post describes how a platform team may develop and manage these **platform capabilities** and gradually evolve a capabilities development and delivery _framework_. The framework should not be designed up front, but platform architects should help it emerge by building prototypical application services and developing initial capabilities for them, as described herein.

## Develop prototype application services

A prerequisite for developing a platform-level shared capability is a representative prototype of the application services wherein the capability will be used. For example, to research and develop service-to-service authentication and authorization mechanisms, two communicating application-level services must exist first; to develop a traffic management capability, one must have application services to route traffic to.

And so we come to the first step in developing platform capabilities: **platform developers and application developers must cooperate to develop prototype application services that are truly representative of application-level scenarios**. Not only must the two groups develop _initial_ prototypes, they must also continuously improve and expand such prototypes to cover more scenarios and adapt to inevitable changes in the organization's environment.

Architects and product managers should do the following to develop prototype application services:

- Interview leads, reverse-engineer codebases and conduct experiments to identify and prioritize the most important and most typical scenarios and required capabilities for the organization's application services
- Ensure all prototype application service code is parameterized and names are extracted
- Ensure that any senior developer can automatically reify a development environment with a single command; and conduct research and development using the prototypes

Several iterations with several application service teams and platform capability teams will probably be required to refine prototype code and ensure coverage of essential scenarios.

## Develop and deliver capabilities

As development of prototype application services begins, development of initial individual capabilities may also begin, as well as early planning for a standard capability development and delivery framework. Early capability development should focus on individual capabilities rather than a general framework; experiments using these initial individual capabilities will guide and inform planning and design of the greater framework. Just as prototype application services guide development of individual capabilities, so too individual capabilities guide development of a capability framework.

### Develop capabilities

Capabilities should be developed and released as follows:

1. Define or refine definition of desired capability
1. Research and develop implementations for capability
1. Deliver capability
1. Gather feedback and learnings and go to 1

For example, a capability for managing secret configuration might follow this storyline:

1. Define desired capability:
    - inject secret configuration as key-value pairs at service start time
2. Research and develop implementations for capability
    - inject Vault agent configuration as pod sidecar using Helm charts
    - deploy Vault admission controller system
    - integrate Vault secrets with Kubernetes Secrets using [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)
3. Deliver capability
    - document how to configure Vault agent in a pod sidecar
    - automatically configure Vault agent with default configuration via a Helm chart
    - automatically configure Vault agent via an admission controller
4. Gather feedback and learnings and iterate
    - adjust exposed configuration options and APIs
    - change implementation
    - support TLS secrets specially

Every capability team will require its members to have expert-level domain knowledge in that capability, alleviating the need for developers in application teams to be expert in the domain. Developers on the team will develop the internal implementation of the capability based on their expertise in it, application service requirements, and the constraints imposed by the organization's environment. PMs will share that knowledge with other partners and users. Team members will participate in external industry communities related to their domain as well to keep abreast of new opportunities and developments.

Capabilities themselves may be implemented in many ways. They have often been built as programming language libraries to be imported into applications in source code, at build time and/or at run time. In cloud-native applications, capabilities are often built as independent processes which communicate with a service's main process via transports like HTTP, GRPC or TCP. In Kubernetes, supporting processes are typically deployed as sidecars in a pod or daemonsets on every node. Mutating admission controllers can also modify capabilities of a pod by modifying their configuration.

As capabilities are developed, a development framework should also emerge to assist with and coordinate fruitful patterns and should include the following:

- Several viable options and examples for developing platform capabilities within the organization, such as operators, templating tools, daemonsets or pod sidecars
- Ability to provision a productive development environment for app and platform research and development

### Deliver capabilities

When ready, platform teams must package and deliver their capability to be used by application teams. To this end, platform architects must gradually develop and manage a standard framework to guide capability developers in delivering and supporting their capabilities, and to provide a rational, consistent experience for application developers using them.

Once a given capability has been initially developed, it should be integrated and tested in application services in the following progression, which a framework should emerge to guide and facilitate:

1. Document required capability configuration and inform users how to set up the capability manually
    1. Verify that application developers are satisfied with the _functionality_ of the capability
1. Inject capability and default configuration via toggles and tags
    1. Verify that application developers are satisfied with the exposed configuration options
1. Inject capability automatically and transparently
    1. At build time with e.g., `helm`, `kustomize`
    1. At deploy time with e.g., mutating admission controllers
    1. At run time with e.g., daemonsets and network proxies

Just as _application_ delivery is only complete when customers begin using the application, platform _capability_ delivery is only complete when application teams begin using the capability in production. The top goal of a platform capability framework should be to provide guided, standard ways to deliver platform capabilities to application developers. As individual capabilities are developed and tested, good general designs and strategies for capability delivery and integration will emerge and should influence development and evolution of the general framework. 

Dimensions a platform capability delivery framework should consider making possible include the following:

- To enable the capability, must the capability team team a) deploy and manage a service such as an operator; or b) package and publish a library; or c) something else?
- To enable a capability, must application developers a) explicitly integrate the capability in source code or infrastructure configuration or b) is it transparently injected?
- May application developers a) toggle and configure a capability or b) not?

## Summary

Platform teams promise to multiply the efficiency of application service teams by centralizing knowledge about and management of shared application capabilities like identity and observability. Help both platform and application teams succeed by providing platform capability development and delivery frameworks to guide them.