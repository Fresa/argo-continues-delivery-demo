Using module ".\k8s\dashboard\k8s-dashboard.psm1"
Using module ".\docker\registry\docker-registry.psm1"
Using module ".\argo\cd\argo-cd.psm1"
Using module ".\argo\cd\argo-cd-server.psm1"
Using module ".\argo\workflow\argo.psm1"
Using module ".\argo\workflow\argo-server.psm1"
Using module ".\argo\events\argo-events.psm1"
Using module ".\argo\events\code-pushed-gateway.psm1"
Using module ".\log.psm1"

class KindCluster 
{
    [string]$Name
    [string]$Context
    [string]$Environment
    [K8sDashboard]$Dashboard

    [Log] $Log = [Log]::new([KindCluster])

    KindCluster(
        [string]$environment,
        [K8sDashboard]$dashboard
    )
    {
        $this.Name = "argo-demo-$environment"
        $this.Context = "kind-$($this.Name)"
        $this.Dashboard = $dashboard
        $this.Environment = $environment
    }

    [void] UseContext() 
    {
        if ((kubectl config current-context) -ne $this.Context)
        {
           $this.Log.Info($(kubectl config use-context $this.Context))
        }
    }

    [void] Create()
    {
        kind create cluster --name $this.Name --config "$PSScriptRoot\kind\config.yaml"

        $(kind get nodes --name $this.Name) | ForEach-Object
        {
            $this.Log.Info($(kubectl annotate node "$_" "kind.x-k8s.io/registry=local:5001"))
        }
    }

    [void] Delete()
    {
        kind delete cluster --name $this.Name
    }
}

class KindApplicationCluster : KindCluster
{
    [ArgoCD]$ArgoCD = [ArgoCD]::new()
    [ArgoCDServer]$ArgoCDServer

    KindApplicationCluster(
        [string]$environment,
        [K8sDashboard]$dashboard,
        [ArgoCDServer]$argoCDServer
    ) : base($environment, $dashboard) 
    {
        $this.ArgoCDServer = $argoCDServer
    }

    [void] CreateDemoApp()
    {
        $this.ArgoCDServer.CreateDemoApp($this.Environment)
    }
}

class KindCICluster : KindCluster
{
    [Argo]$Argo = [Argo]::new()
    [ArgoServer]$ArgoServer

    [ArgoEvents]$ArgoEvents = [ArgoEvents]::new()
    [CodePushedGateway]$CodePushedGateway

    [DockerRegistry]$DockerRegistry

    KindCICluster(
        [string]$environment,
        [K8sDashboard]$dashboard,
        [ArgoServer]$ArgoServer,
        [DockerRegistry]$dockerRegistry,
        [CodePushedGateway]$codePushedGateway
    ) : base($environment, $dashboard) 
    {
        $this.ArgoServer = $ArgoServer
        $this.DockerRegistry = $dockerRegistry
        $this.CodePushedGateway = $codePushedGateway
    }
}

class KindClusters : System.Collections.ArrayList
{
    KindClusters()
    {
        $this.Add([KindCICluster]::new(
            "ci",
            [K8sDashboard]::new(8001),
            [ArgoServer]::new(),
            [DockerRegistry]::new(),
            [CodePushedGateway]::new()))
        $this.Add([KindApplicationCluster]::new(
            "test", 
            [K8sDashboard]::new(8002), 
            [ArgoCDServer]::new(8080)))
        $this.Add([KindApplicationCluster]::new(
            "prod", 
            [K8sDashboard]::new(8003), 
            [ArgoCDServer]::new(8081)))
    }

    [System.Collections.ArrayList] GetApplicationClusters()
    {
        return $this | Where-Object { $_.Environment -ne "ci" }
    }

    [KindCICluster] GetCICluster()
    {
        return $this | Where-Object { $_.Environment -eq "ci" } | Select-Object -First 1
    }
}