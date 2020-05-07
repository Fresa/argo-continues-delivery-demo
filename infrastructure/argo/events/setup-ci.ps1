kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-event-source.yaml"
kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-gateway.yaml"
kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-sensor.yaml"