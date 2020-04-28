kubectl create namespace argocd
kubectl apply -n argocd -f "$PSScriptRoot\install.yaml"