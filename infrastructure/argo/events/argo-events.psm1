Using module "..\..\log.psm1"

class ArgoEvents {
    [Log] $Log = [Log]::new([ArgoEvents])

    [void] Install()
    {
        $this.Log.Info($(kubectl create namespace argo-events))
        $this.Log.Info($(kubectl apply -f "$PSScriptRoot\install.yaml"))

        $this.Log.Info($(kubectl -n argo-events create secret generic git-ssh --from-file=key=$global:HOME/.ssh/github))
        $this.Log.Info($(kubectl -n argo-events create secret generic git-known-hosts --from-file=ssh_known_hosts=$global:HOME/.ssh/known_hosts))

        # CI
        $gitApiKeyFile = "$PSScriptRoot\git-api-key.txt"
        if (-not ($gitApiKeyFile | Test-Path)) 
        {
            $gitApiKey = Read-Host -Prompt "Could not find '$gitApiKeyFile'. Please input git api key"
            New-Item -Path $gitApiKeyFile -ItemType File 
            Set-Content -NoNewline -Path $gitApiKeyFile -Value $gitApiKey
        }

        $this.Log.Info($(kubectl -n argo-events create secret generic git-api-key --from-file=key=$gitApiKeyFile))
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-event-source.yaml"))
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-gateway.yaml"))
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-sensor.yaml"))
    }
}