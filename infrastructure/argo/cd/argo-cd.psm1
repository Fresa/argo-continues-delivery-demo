Using module "..\..\log.psm1"

class ArgoCD {
    [Log] $Log = [Log]::new([ArgoCD])

    [void] Install()
    {
        $this.Log.Info($(kubectl create namespace argocd))
        $this.Log.Info($(kubectl apply -n argocd -f "$PSScriptRoot\install.yaml"))
    }

    [void] DownloadCLI(
        [string]$version
    )
    {        
        $this.Log.Info("Downloading version $version")

        $filename = "$PSScriptRoot\argo.exe"
        if (Test-Path $filename)
        {
            $this.Log.Warning("$filename already exists")
            return;
        }

        Invoke-WebRequest -Uri "https://github.com/argoproj/argo-cd/releases/download/v$version/argocd-windows-amd64.exe" -OutFile $filename
        $this.Log.Info("$filename downloaded.")
    }
}