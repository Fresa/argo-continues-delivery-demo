param(
    [parameter(Mandatory=$true,
        HelpMessage="Port to login")]
    [String]$port,
    [parameter(Mandatory=$true,
        HelpMessage="Environment where the application is created")]
    [String]$environment
)

& "$PSScriptRoot\login.ps1" -port $port
kubectl apply -n argocd -f "$PSScriptRoot\application-$environment.yaml"
argocd app create demo --repo https://github.com/Fresa/argo-continues-delivery-demo-config.git --path helm --dest-server https://kubernetes.default.svc --dest-namespace default --upsert