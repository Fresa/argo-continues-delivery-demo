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

    [void] Create(
        [int]$registryPort
    )
    {
        $localIpAddress = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred | 
            where-object { $_.InterfaceAlias -notmatch 'Loopback'} | 
            select-object -First 1 | 
            select-object -exp IPAddress

        $registryAddressAlias = "local:$registryPort"

@"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
  # Need to define how to communicate with a local docker repo from Containerd. 
  # This is needed to be able to communicate with insecure image registries, 
  # similar to what the insecure registry setting in Docker does; https://docs.docker.com/registry/insecure/
  # https://kind.sigs.k8s.io/docs/user/local-registry/#create-a-cluster-and-registry
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."$registryAddressAlias"]
    endpoint = ["http://$($localIpAddress):$($registryPort)"]
"@ | Out-File "$PSScriptRoot\kind\config.yaml"

        kind create cluster --name $this.Name --config "$PSScriptRoot\kind\config.yaml"
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
        [KindCluster]$kindCluster,
        [ArgoCDServer]$argoCDServer
    ) : base($kindCluster.Environment, $kindCluster.Dashboard) 
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
        [KindCluster]$kindCluster,
        [ArgoServer]$ArgoServer,
        [DockerRegistry]$dockerRegistry,
        [CodePushedGateway]$codePushedGateway
    ) : base($kindCluster.Environment, $kindCluster.Dashboard) 
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
        $ciCluster = [KindCluster]::new(
            "ci", 
            [K8sDashboard]::new(8001))
        $this.Add([KindCICluster]::new(
            $ciCluster,
            [ArgoServer]::new(
                $ciCluster.Context),
            [DockerRegistry]::new(
                $ciCluster.Context),
            [CodePushedGateway]::new(
                $ciCluster.Context)))
        
        $testCluster = [KindCluster]::new(
            "test", 
            [K8sDashboard]::new(8002))
        $this.Add([KindApplicationCluster]::new(
            $testCluster, 
            [ArgoCDServer]::new(
                $testCluster.Context,
                8080)))

        $prodCluster = [KindCluster]::new(
            "prod", 
            [K8sDashboard]::new(8003))
        $this.Add([KindApplicationCluster]::new(
            $prodCluster, 
            [ArgoCDServer]::new(
                $prodCluster.Context,
                8081)))
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