param(
    [parameter(Mandatory=$true,
        HelpMessage="Example: 1.4.3. Releases: https://github.com/argoproj/argo-cd/releases")]
    [String]$version
)
Write-Host "Downloading version $version"

$filename = "argocd.exe"
if (Test-Path $filename){
    Write-Host "$filename already exists"    
    return;
}

Invoke-WebRequest -Uri "https://github.com/argoproj/argo-cd/releases/download/v$version/argocd-windows-amd64.exe" -OutFile $filename
Write-Host "$filename downloaded."