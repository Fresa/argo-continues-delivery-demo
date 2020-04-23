kubectl create namespace argo
kubectl apply -n argo -f "$PSScriptRoot\workflow-controller-config-map.yaml"
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml

kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default