kubectl create namespace argo
kubectl apply -n argo -f "$PSScriptRoot\install.yaml"
kubectl apply -n argo -f "$PSScriptRoot\workflow-controller-config-map.yaml"

kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default