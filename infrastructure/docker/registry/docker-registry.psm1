Using module "..\..\port-forward.psm1"

class DockerRegistry {
    [string]$Service = "docker-registry"
    [string]$Namespace = "default"
    [int]$ContainerPort = 5000
    [int]$Port = 5001
    [PortForward]$PortForwarder

    DockerRegistry()
    {
        $this.PortForwarder = [PortForward]::new("service/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort)
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