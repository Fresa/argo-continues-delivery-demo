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

return @{ 
    "CI" = [KindCluster]::new("argo-demo-ci", 8001)    
    "Test" = [KindCluster]::new("argo-demo-test", 8002)
    "Prod" = [KindCluster]::new("argo-demo-prod", 8003)
}