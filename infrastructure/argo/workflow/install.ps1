kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml
kubectl apply -f workflow-controller-config-map.yaml

kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default