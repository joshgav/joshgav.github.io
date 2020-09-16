---
layout: post
title:  "How container streaming (exec, port-forward) works in Kubernetes"
date:   2020-09-16 11:30:00 -0500
categories: kubernetes kubelet exec
---

# Overview of Kubelet

Kubernetes' **kubelet** is a server and controller which runs on every cluster node as an agent to allocate compute, storage and network resources for workloads described by **PodSpec**s retrieved from the API server. Not only does the kubelet manage pods for Kubernetes in "connected" mode, but it can also (or alternatively) read PodSpecs from the local filesystem or an HTTP endpoint in "standalone" mode. In short, the kubelet is an independent implementation of PodSpec.

> For more on kubelet's standalone mode check out [this article](https://coreos.com/blog/introducing-the-kubelet-in-coreos.html) and [this tutorial](https://github.com/kelseyhightower/standalone-kubelet-tutorial) from Kelsey Hightower.

Kubelet handles the heavy lifting of provisioning virtual networks, allocating and attaching block storage and running container images by calling a **container runtime** like Docker via Kubelet's Container Runtime Interface (CRI), as defined in [this protobuf spec](https://github.com/kubernetes/cri-api/blob/master/pkg/apis/runtime/v1alpha2/api.proto). A shim for CRI from Docker's native API is [included](https://github.com/kubernetes/kubernetes/tree/master/pkg/kubelet/dockershim) in the kubelet, or you can follow [these instructions](https://kubernetes.io/docs/setup/production-environment/container-runtimes/) to install and use another runtime like CRI-O.

Amongst the procedures offered by CRI's [RuntimeService](https://github.com/kubernetes/cri-api/blob/205a053b09eb766d86191392b3e6bd94df6ceb0c/pkg/apis/runtime/v1alpha2/api.proto#L33-L110) one finds **Exec**, **Attach** and **PortForward**, likely familiar to anyone who works with containers. These ultimately are core to the `kubectl exec ...`, `kubectl run -it ...`, `kubectl port-forward` and even the new `kubectl [alpha] debug ...` commands that container developers know and love. Following is how these commands and procedures work together to connect your terminal to a process in a worker node.

# exec

First let's walk through what happens when you run `kubectl exec -it ${pod_name} sh --container ${container_name}` to run a shell in the context of an existing container. We'll borrow and refer to the following diagram from [this k8s enhancement proposal](https://github.com/kubernetes/enhancements/blob/master/keps/sig-node/20191205-container-streaming-requests.md).

<img src="https://raw.githubusercontent.com/kubernetes/enhancements/master/keps/sig-node/kubelet-proxied-streaming-request-sequence.png" style="margin-left: 40px;" />

## 1. client

Based on its arguments, `kubectl exec` builds a URL for and opens an HTTP/2 connection with the API server. The local terminal's standard I/O streams (stdin, stdout, stderr) are connected to this transport. The URL formed for the API server is `http[s]://${api_server}/ns/${pod_namespace}/pods/${pod_name}/exec?stdin=true&stdout=true&stderr=true&tty=true&container=${container_name}&command=sh`.

### Source refs:

* `kubectl exec` [[1](https://github.com/kubernetes/kubectl/blob/d70ead5fcaa0e8f8246715584147ba3bfd081411/pkg/cmd/exec/exec.go)]

## 2. apiserver

The corev1/pods APIService accepts the incoming request and handles it per [its registration](https://github.com/kubernetes/kubernetes/tree/master/pkg/registry/core/pod). Specifically, it discovers the address and port of the Node/Kubelet running the indicated container and opens a streaming proxy connection to it. This stream is bound to the streams from the incoming request.

The URL for the kubelet server is of form `http[s]://${node_ip}:${kubelet_port}/${subresource}/${pod_namespace}/${pod_name}/${container_name}` where `${subresource}` can be `exec`, `attach`, `portforward` or a few others.

### Source refs:
  
* `registry/core/pod.streamLocation` [[1](https://github.com/kubernetes/kubernetes/blob/9621ac6ec7eddccdf007c043272c81b23408704b/pkg/registry/core/pod/strategy.go#L506-L511)]

## 3. kubelet

The kubelet provides its own API server which accepts the incoming request from the API server and forwards it to the container runtime. The kubelet then continues to proxy I/O streams between the API server and the container runtime. An option exists to hand off the stream with the container runtime directly to the API server (rather than continuing to proxy it through kubelet), but it has been deprecated.

The exec, attach, port-forward and logs actions are handled by Kubelet's "debugging handlers." They can be disabled by setting [EnableDebuggingHandlers](https://github.com/kubernetes/kubelet/blob/f87179761b5b3b817cf86fdf2e31801c61a8db7e/config/v1beta1/types.go#L255-L262) to `false` in the global kubelet configuration, or by setting the flag `--enable-debugging-handlers=false` on an individual kubelet. **Note** that this will disable container logs via `kubectl logs` as well!

### Source refs:

* `kubelet/server/NewServer(enableDebuggingHandlers)` [[1](https://github.com/kubernetes/kubernetes/blob/3d52b8b5d60e1f74f4207f1d046734878297e354/pkg/kubelet/server/server.go#L243-L253)]
* `kubelet/server/server.InstallDebuggingHandlers` [[2](https://github.com/kubernetes/kubernetes/blob/3d52b8b5d60e1f74f4207f1d046734878297e354/pkg/kubelet/server/server.go#L411)]
* `kubelet/server/server.getExec` [[3](https://github.com/kubernetes/kubernetes/blob/3d52b8b5d60e1f74f4207f1d046734878297e354/pkg/kubelet/server/server.go#L795-L821)]

## 4. CRI

Finally the container runtime - or runtime shim in Docker's case - receives the request from kubelet and takes the steps necessary to create and execute a process in the namespaces and cgroups of the target container. In Docker this is achieved by calling [github.com/moby/moby/client#Client.ContainerExecCreate](https://pkg.go.dev/github.com/moby/moby/client#Client.ContainerExecCreate).

In truth `exec` itself can be executed without a persistent connection, in which case you wouldn't be able to send stdin or receive stdout from the executed command. When you specify `-i -t` with `exec` an attach action is executed immediately after exec to provide a persistent connection.

### Source refs:

* `kubelet/cri/streaming.NewServer` [[1](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/cri/streaming/server.go#L125-L133)]
* `kubelet/cri/streaming/server.serveExec` [[2](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/cri/streaming/server.go#L265-L297)]
* `kubelet/cri/streaming/remotecommand/ServeExec` [[3](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/cri/streaming/remotecommand/exec.go#L44)]
* `kubelet/dockershim/NativeExecHandler.ExecInContainer` [[4](https://github.com/kubernetes/kubernetes/blob/fe1aeff2d2341e3d9a553534c814ad40f8219e35/pkg/kubelet/dockershim/exec.go#L64)]
* `kubelet/dockershim/libdocker/kubeDockerClient.StartExec` [[5](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/dockershim/libdocker/kube_docker_client.go#L461)]
* `moby/moby/client/Client.ContainerExecCreate` [[6](https://pkg.go.dev/github.com/moby/moby/client#Client.ContainerExecCreate)]

# port-forward

Whereas exec and attach work in the context of a container, port-forward communicates with the "pod", or more specifically with the pod's network namespace. In Kubelet's built-in Docker CRI shim, port forwarding is accomplished with the following command. The "sandbox" in CRI represents the pod context.

`nsenter -t ${sandbox_pid} -n socat - TCP4:localhost:${target_port}`

### Source Refs

* `kubelet/cri/streaming/portforward.ServePortForward` [[1](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/cri/streaming/portforward/portforward.go#L36-L53)]
* `kubelete/dockershim/streamingRuntime.portForward` [[2](https://github.com/kubernetes/kubernetes/blob/e83412c331ae72718a84623870c420e6daf58a25/pkg/kubelet/dockershim/docker_streaming_others.go)]

# logs

Requests for container logs also pass through the kubelet to the CRI and are streamed back to the client.

### Source Refs

* `kubelet/server/server.InstallDebuggingHandlers` [[1](https://github.com/kubernetes/kubernetes/blob/fd9828b02a786d4fa8d2add04c37e33a616d0087/pkg/kubelet/server/server.go#L482-L488)]
* `kubelet/server/server.getContainerLogs` [[2](https://github.com/kubernetes/kubernetes/blob/fd9828b02a786d4fa8d2add04c37e33a616d0087/pkg/kubelet/server/server.go#L595-L661)]
* `dockershim/dockerService.GetContainerLogs` [[3](https://github.com/kubernetes/kubernetes/blob/fe1aeff2d2341e3d9a553534c814ad40f8219e35/pkg/kubelet/dockershim/docker_legacy_service.go#L49-L92)]