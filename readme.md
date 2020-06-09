![Dag Visualization of the sample beam app on spark](https://github.com/THEjoezack/beam-on-spark-on-kubernetes/raw/master/dag-visualization.png)

# Deploying Beam apps to Spark on Kubernetes

This is a simple example of how you can deploy the ["Getting Started" beam app](https://beam.apache.org/get-started/wordcount-example/) on Spark on Kubernetes, via the open-source [GCP Operator](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator).

## Requirements

- Docker
- Kubernetes
- Helm

## Install the Spark Operator with Helm

This step installs a Spark operator that is responsible for processing job requests and starting the appropriate drivers and executors.

```bash
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
kubectl create namespace spark-operator
kubectl create namespace spark-jobs
helm install sparkoperator incubator/sparkoperator --namespace spark-operator --set sparkJobNamespace=spark-jobs
helm status sparkoperator --namespace spark-operator
```

## Build a sample Spark container

There is a Dockerfile located in this directory that will compile the sample beam app, and bundle it into a container with Spark and some randomly generated data.

```bash
docker build . -t beam-sample
```

## Submit your job

This command will submit a job to the Spark Operator, which is responsible for creating the driver and exectors.

The job is named in this file as "beam-sample".

```bash
kubectl apply -f service-account.yaml -n spark-jobs
kubectl apply -f job.yaml -n spark-jobs
```

## Monitor the job

The we interface is running inside the Kubernetes cluter, you have to port forward to access it.

The job runs quickly, and the driver shuts down afterwards so you have act quickly if you want to see the UI.

The output generated in the job is lost when the executors shut down. In a real-world situation you would want to export the data to something like cloud storage or persistent volumes.

```bash
# You should see a driver, and (temporarily) some executors
# The status will show "Completed" once the job is complete
kubectl get pods -n spark-jobs
kubectl get svc -n spark-jobs

# You have to be pretty fast though, once the job completes the UI is non-functional
# (TODO, would love to change this)
kubectl port-forward svc/beam-sample-ui-svc 4040:4040 -n spark-jobs

# You can re-run your job by first deleting, but give the "delete" command a couple seconds
# after it says it's done :)
kubectl delete SparkApplication beam-sample -n spark-jobs
kubectl apply -f job.yaml -n spark-jobs
```

## Cleaning up

All done? You can delete the operator and it will clean everything else up.

```bash
helm uninstall sparkoperator --namespace spark-operator
```

## Resources

- https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
- https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/tree/master/docs
- https://github.com/helm/charts/blob/ed7c211dc21f8f4435c802782a76ffdf4309e400/incubator/sparkoperator/README.md
