Using module "..\..\port-forward.psm1"
Using module "..\..\log.psm1"

class ArgoServer {
    [string]$Service = "argo-server"
    [string]$Namespace = "argo"
    [int]$ContainerPort = 2746
    [int]$Port = 2746
    [PortForward]$PortForwarder
    [Log] $Log = [Log]::new([ArgoServer])

    ArgoServer()
    {
        $this.PortForwarder = [PortForward]::new("deployment/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort)
    }

    [void] Install()
    {
        $this.Log.Info($(kubectl create namespace argo))
        $this.Log.Info($(kubectl apply -n argo -f "install.yaml"))
        $this.Log.Info($(kubectl apply -n argo -f "workflow-controller-config-map.yaml"))
        
        $this.Log.Info($(kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default))
    }

    [void] DownloadCLI(
        [string]$version
    )
    {
        $this.Log.Info("Downloading version $version")

        $filename = "$PSScriptRoot\argo.exe"
        if (Test-Path $filename){
            $this.Log.Warning("$filename already exists")
            return;
        }

        Invoke-WebRequest -Uri "https://github.com/argoproj/argo/releases/download/v$version/argo-windows-amd64" -OutFile $filename
        $this.Log.Info("$filename downloaded.")
    }

    [void] PortForward()
    {
        $this.PortForwarder.Start(120)
    }

    [void] StopPortForwarding()
    {
        $this.PortForwarder.Stop()
    }

    [void] WaitUntilAvailable()
    {
        if (-not($this.PortForwarder.TryWaitUntilAvailable("http://127.0.0.1:$($this.PortForwarder.From)")))
        {
            $this.PortForwarder.OutputInfo()
        }
    }
}