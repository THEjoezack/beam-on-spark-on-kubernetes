You need Docker, Kubernetes, Helm, Maven

(reset the kluster)
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
kubectl create namespace spark-operator
helm install sparkoperator incubator/sparkoperator --namespace spark-operator --set sparkJobNamespace=default
helm status sparkoperator --namespace spark-operator

docker build . -t beam-sample

kubectl apply -f job.yaml

## Resources

https://github.com/GoogleCloudPlatform/spark-on-k8s-operator
https://github.com/helm/charts/blob/ed7c211dc21f8f4435c802782a76ffdf4309e400/incubator/sparkoperator/README.md
