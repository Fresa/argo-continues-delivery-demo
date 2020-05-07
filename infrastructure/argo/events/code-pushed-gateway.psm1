Using module "..\..\port.psm1"

class CodePushedGateway 
{
    [string]$Service = "code-pushed-gateway"
    [string]$Namespace = "argo-events"
    [int]$ContainerPort = 12000
    [int]$Port = 12000

    [void] PortForward()
    {
        [Port]::Forward("deployment/$($this.Service)", $this.Namespace, $this.Port, $this.ContainerPort, 120)
    }

    [void] StopPortForwarding()
    {
        [Port]::Stop("deployment/$($this.Service)")
    }

    [void] WaitUntilAvailable()
    {
        if (-not([Port]::TryWaitUntilAvailable("http://127.0.0.1:$($this.Port)/pushed")))
        {
            [Port]::OutputInfo("deployment/$($this.Service)")
        }
    }
}