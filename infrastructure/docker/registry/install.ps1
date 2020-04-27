kubectl apply -f "$PSScriptRoot\registry.yaml"
kubectl apply -f "$PSScriptRoot\registry-config-map.yaml"
kubectl apply -f "$PSScriptRoot\registry-service.yaml"