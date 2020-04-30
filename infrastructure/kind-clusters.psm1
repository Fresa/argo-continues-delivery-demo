class KindCluster {
    [string]$Name
    [string]$Context
    [int]$Port

    KindCluster(
        [string]$name,
        [int]$port
    ){
        $this.Name = $name
        $this.Context = "kind-$name"
        $this.Port = $port
    }
}

class KindClusters : System.Collections.ArrayList
{
    KindClusters(){
        $this.Add([KindCluster]::new("argo-demo-ci", 8001))
        $this.Add([KindCluster]::new("argo-demo-test", 8002))
        $this.Add([KindCluster]::new("argo-demo-prod", 8003))
    }

    [System.Collections.ArrayList] static GetApplicationClusters(){
        return [KindClusters]::new() | Where-Object { $_.Name -ne "argo-demo-ci" }
    }

    [KindCluster] static GetCICluster(){
        return [KindClusters]::new() | Where-Object { $_.Name -eq "argo-demo-ci" } | Select-Object -First 1
    }
}