![Dag Visualization of the sample beam app on spark](https://github.com/THEjoezack/beam-on-spark-on-kubernetes/raw/master/dag-visualization.png)

# Deploying Beam apps to Spark on Kubernetes

This repository is a simple example of how you can deploy the [Beam "Getting Started" beam app](https://beam.apache.org/get-started/wordcount-example/) on Spark on Kubernetes, via the open-source [GCP Operator](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator)

## Requirements

- Docker
- Kubernetes
- Helm

## Install the Spark Operator with Helm

```bash
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
kubectl create namespace spark-operator
helm install sparkoperator incubator/sparkoperator --namespace spark-operator --set sparkJobNamespace=default
helm status sparkoperator --namespace spark-operator
```

## Build a sample Spark container

There is a Dockerfile located in this directory that will bundle the sample beam application into a Spark container.

```bash
docker build . -t beam-sample
```

## Submit your job

This command will submit a job to the Spark Operator, which is responsible for creating the driver and exectors.

```bash
kubectl apply -f job.yaml
```

## Monitor the job

The we interface is running inside Kubernetes cluter, you have to port forward to access it.

```bash
# You should see a driver, and (temporarily) some executors
# The status will show "Completed" once the job is complete
kubectl get pods
kubectl get svc

# You have to be pretty fast though, once the job completes the UI is non-functional
# (TODO, would love to change this)
kubectl port-forward svc/beam-sample-ui-svc 4040:4040

# You can re-run your job by first deleting, but give the "delete" command a couple seconds
# after it says it's done :)
kubectl delete SparkApplication beam-sample
kubectl apply -f job.yaml
```

## Resources

- https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
- https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/tree/master/docs
- https://github.com/helm/charts/blob/ed7c211dc21f8f4435c802782a76ffdf4309e400/incubator/sparkoperator/README.md
