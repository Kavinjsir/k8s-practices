## Create a Kind cluster

```sh
kind create cluster --config kind/config.yaml
```

## Deploy Kube-prometheus

#### 1. Prerequisites

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
