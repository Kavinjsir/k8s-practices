## Create a Kind cluster

**(Following practices also applies to minikube; The [Official Doc](https://github.com/prometheus-operator/kube-prometheus/blob/v0.13.0/examples/minikube.jsonnet) can be an else ref.)**

```sh
kind create cluster --config cluster/kind-config.yaml
```

## Deploy Kube-prometheus

### 0. Prerequisites

The `kube-prometheus` uses jsonnet to generate k8s manifests, which requires:

- jb: A jsonnet package manager
- jsonnet: The jsonnet interpreter

The jsonnet interpreter can convert the jsonnet code to `json` files.
To further convert `json` files to `yaml` files as k8s manifests, it is recommended to install `gojsontoyaml`.

Below are installation commands for **macos**:

```sh
brew install jsonnet-bundler

go install github.com/google/go-jsonnet/cmd/jsonnet@latest

go install github.com/brancz/gojsontoyaml@latest
```

Also, make sure you have a Kubernetes cluster prepared. A `kind` cluster should be enough.

### 1. Generate Kubernetes manifests from kube-prometheus

Go to path `monitoring`, which is the working directory for the following practices.

```sh
# Install the kube-prometheus library
jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main
```

After executed, a `vendor` folder should be created containing the source code of kube-prometheus.

Now, run `./build.sh main.jsonnet`, this will:

1. Integrate our configuration with the kube-prometheus source code
2. Convert the integration result from `json` to `yaml`
3. Cleanup the folder (Drop unnecessary files created in the above process)

After this step, a `manifests` folder should be created. This contains all the manifests that are ready to deploy.

### 2. Deploy the kube-prometheus manifests

First, install prometheus-operator CRDs.

```sh
kubectl apply --server-side -f manifests/setup
```

Wait till the installation complete.

```sh
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
```

Then, apply CRs and k8s native resources.

```sh
kubectl apply -f manifests/
```

### 3. Validate Prometheus and Grafana status

Run `kubectl get all -n monitoring` to see if all resources are in healthy states.

If so, check `services`, there should be one for `prometheus-k8s` and one for `grafana`:
<img width="811" alt="Screenshot 2023-07-19 at 9 33 49 PM" src="https://github.com/Kavinjsir/k8s-practices/assets/18136486/9dc6536a-fabf-4211-b30a-b0e5498855a1">

Use `kubectl port-forward -n monitoring svc/<service-name> <port>` to proxy the endpoint to your local:

```sh
k port-forward -n monitoring svc/prometheus-k8s 9090
k port-forward -n monitoring svc/grafana 3000
```

Now, you can check `prometheus` by visiting `localhost:9090`, I recommend reviewing `/targets` and `service-discovery` routes to see how various resources are covered by the prometheus instance.

Similarly, you can browse `grafana` website at `localhost:30000`, the initial account can be:

```typescript
{
  username: admin;
  password: admin;
}
```

See that there are a `default` folder in the dashboards that provides rich mixins to help you observe your cluster in general:

<img width="957" alt="Screenshot 2023-07-19 at 9 43 17 PM" src="https://github.com/Kavinjsir/k8s-practices/assets/18136486/78f456b8-6619-4f83-839e-73a0550eef7e">

Casually click any dashboards to see if data can be successfully loaded and presented.
