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
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-event-source.yaml"))
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-gateway.yaml"))
        $this.Log.Info($(kubectl apply -n argo-events -f "$PSScriptRoot\code-pushed-sensor.yaml"))
    }
}