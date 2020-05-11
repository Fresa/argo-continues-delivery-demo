Using module "..\..\log.psm1"

class Argo {
    [Log] $Log = [Log]::new([Argo])

    [void] Install()
    {
        $this.Log.Info($(kubectl create namespace argo))
        $this.Log.Info($(kubectl apply -n argo -f "$PSScriptRoot\install.yaml"))
        $this.Log.Info($(kubectl apply -n argo -f "$PSScriptRoot\workflow-controller-config-map.yaml"))
        
        $this.Log.Info($(kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default))
    }

    [void] DownloadCLI(
        [string]$version
    )
    {
        $this.Log.Info("Downloading version $version")

        $filename = "$PSScriptRoot\argo.exe"
        if (Test-Path $filename){
            $this.Log.Warning("$filename already exists")
            return;
        }

        Invoke-WebRequest -Uri "https://github.com/argoproj/argo/releases/download/v$version/argo-windows-amd64" -OutFile $filename
        $this.Log.Info("$filename downloaded.")
    }
}