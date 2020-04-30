class KindCluster {
    [string]$Name
    [string]$Context
    [int]$Port
    [string]$Environment

    KindCluster(
        [int]$port,
        [string]$environment
    ){
        $this.Name = "argo-demo-$environment"
        $this.Context = "kind-$($this.Name)"
        $this.Port = $port
        $this.Environment = $environment
    }
}

class KindApplicationCluster : KindCluster{
    [int]$ArgoCDPort

    KindApplicationCluster(
        [int]$port,
        [string]$environment,
        [int]$ArgoCDPort
    ) : base($port, $environment) {
        $this.ArgoCDPort = $ArgoCDPort
    }
}

class KindClusters : System.Collections.ArrayList
{
    KindClusters(){
        $this.Add([KindCluster]::new(8001, "ci"))
        $this.Add([KindApplicationCluster]::new(8002, "test", 8080))
        $this.Add([KindApplicationCluster]::new(8003, "prod", 8081))
    }

    [System.Collections.ArrayList] static GetApplicationClusters(){
        return [KindClusters]::new() | Where-Object { $_.Environment -ne "ci" }
    }

    [KindCluster] static GetCICluster(){
        return [KindClusters]::new() | Where-Object { $_.Environment -eq "ci" } | Select-Object -First 1
    }
}