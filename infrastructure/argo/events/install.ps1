kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/master/hack/k8s/manifests/installation.yaml

kubectl -n argo-events create secret generic git-ssh --from-file=key=$HOME/.ssh/github
kubectl -n argo-events create secret generic git-known-hosts --from-file=ssh_known_hosts=$HOME/.ssh/known_hosts

kubectl apply -n argo-events -f "$PSScriptRoot\ci-webhook.yaml"
kubectl apply -n argo-events -f "$PSScriptRoot\ci-webhook-gateway.yaml"
kubectl apply -n argo-events -f "$PSScriptRoot\ci-webhook-sensor.yaml"