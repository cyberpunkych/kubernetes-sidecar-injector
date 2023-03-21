# Kubernetes proxy via Sidecar Injector

Spawn sidecar container for every pod with specified label. Based on https://medium.com/@mohllal/kubernetes-sidecar-container-injection-61ecfcc7b22b and https://latest.gost.run/en/tutorials/redirect/.

## Requirments

- [Docker](https://www.docker.com/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Helm](https://helm.sh/)
- Access to a Kubernetes v1.19+ cluster

## Deploying

1. Install the `kubernetes-sidecar-injector` chart

```shell
helm install kubernetes-sidecar-injector charts/kubernetes-sidecar-injector/ \
--values charts/kubernetes-sidecar-injector/values.yaml \
--namespace default
```

2. Install the `gateway` deployment and service

```shell
kubectl apply -f ./gateway.yaml -n default
```

3. Create pod with label for inject:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  labels:
    app: test-pod
    sidecar.me/inject: 'True'
spec:
  # affinity:
  #   nodeAffinity:
  #     requiredDuringSchedulingIgnoredDuringExecution:
  #       nodeSelectorTerms:
  #       - matchExpressions:
  #         - key: kubernetes.io/hostname
  #           operator: In
  #           values:
  #           - cl14dmjve12llfgs08eq-ysac
  containers:
    - name: test-pod
      command: ["tail","-f","/dev/null"]
      image: ubuntu
```
