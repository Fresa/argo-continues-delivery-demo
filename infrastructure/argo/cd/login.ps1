param(
    [parameter(Mandatory=$true,
        HelpMessage="Port to login")]
    [String]$port
)

& "$PSScriptRoot/get-argocd-cli.ps1" -version 1.4.3
argocd login 127.0.0.1:$port --insecure --username admin --password $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | ForEach-Object{ $_.SubString($_.IndexOf("/") + 1) })