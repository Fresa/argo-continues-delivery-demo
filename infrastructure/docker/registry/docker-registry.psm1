Using module "..\..\port-forward.psm1"
Using module "..\..\log.psm1"

class DockerRegistry {
    [string]$Service = "docker-registry"
    [string]$Namespace = "default"
    [int]$ContainerPort = 5000
    [int]$Port = 5001
    [PortForward]$PortForwarder
    [Log]$Log = [Log]::new([DockerRegistry])

    DockerRegistry([string]$context)
    {
        $this.PortForwarder = [PortForward]::new(
            $context, 
            "service/$($this.Service)", 
            $this.Namespace, 
            $this.Port, 
            $this.ContainerPort)
    }

    [void] Install()
    {
        $this.Log.Info($(kubectl apply -f "$PSScriptRoot\registry.yaml"))
        $this.Log.Info($(kubectl apply -f "$PSScriptRoot\registry-config-map.yaml"))
        $this.Log.Info($(kubectl apply -f "$PSScriptRoot\registry-service.yaml"))
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