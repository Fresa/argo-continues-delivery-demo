Using module "..\..\port.psm1"

class DockerRegistry {
    [string]$Service = "docker-registry"
    [string]$Namespace = "default"
    [int]$ContainerPort = 5000
    [int]$Port = 5001

    [void] PortForward()
    {
        [Port]::Forward("service/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort, 120)
    }

    [void] StopPortForwarding(){
        [Port]::Stop("service/$($this.Service)")
    }

    [void] WaitUntilAvailable(){
        if (-not([Port]::TryWaitUntilAvailable("http://127.0.0.1:$($this.Port)")))
        {
            [Port]::OutputInfo("service/$($this.Service)")
        }
    }
}