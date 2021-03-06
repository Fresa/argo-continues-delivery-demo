Using module "..\..\port-forward.psm1"

class CodePushedGateway 
{
    [string]$Service = "code-pushed-gateway"
    [string]$Namespace = "argo-events"
    [int]$ContainerPort = 12000
    [int]$Port = 12000
    [PortForward]$PortForwarder

    CodePushedGateway([string]$context)
    {
        $this.PortForwarder = [PortForward]::new(
            $context,
            "deployment/$($this.Service)", 
            $this.Namespace, 
            $this.Port, 
            $this.ContainerPort)
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
        if (-not($this.PortForwarder.TryWaitUntilAvailable(
            "http://127.0.0.1:$($this.PortForwarder.From)", 
            [system.net.httpstatuscode]::NotFound)))
        {
            $this.PortForwarder.OutputInfo()
        }
    }
}