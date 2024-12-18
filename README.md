# 用于在 K8S 中注册 mock node 做测试

## 如何使用

```bash
helm upgrade -i -n virtual-node virtual-node ./ --set nodeNum=<你想要的注册的节点数>
```

然后会创建一堆 pod 到 virtual-node namespace 并注册同等数量的 node

目前我们给机器写死了用资源占用

```json
    {
      "{{ include "virtual-node.name" $ }}-{{ $i }}": {
        "cpu": "64",
        "memory": "256Gi",
        "pods": "600"
      }
    }
```

如果想改的话，可以直接进到 templates/cm.yaml 中改，添加自己自定义的 node 资源列表

## 如何调度 pod 到 virtual-node 上

virtual-node 默认打了 `virtual-kubelet.io/provider=mock` 的污点，需要给 pod 容忍污点，下面是创建的一个 deployment 示例
（可以通过修改 values.yaml 中的 disable-taint=true 来取消污点）
```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: test-virtual-node
spec:
  replicas: 10
  selector:
    matchLabels:
      name: test-virtual-node
  template:
    metadata:
      labels:
        name: test-virtual-node
    spec:
      tolerations:
        - key: virtual-kubelet.io/provider
          value: mock
          effect: NoSchedule
      containers:
        - name: busybox
          image: busybox
          resources:
            limits:
              cpu: "20"
              memory: 20Gi
```

## 在 virtual kubelet 中调度 pod 


```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: test-quota
  namespace: test-ns
spec:
  replicas: 10
  selector:
    matchLabels:
      name: test-quota
  template:
    metadata:
      labels:
        name: test-quota
    spec:
      tolerations:
        - key: virtual-kubelet.io/provider
          value: mock
          effect: NoSchedule
      containers:
        - name: busybox
          image: busybox
          resources:
            limits:
              cpu: "20"
              memory: 20Gi
```
