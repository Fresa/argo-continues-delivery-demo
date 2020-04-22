param(
    [parameter(Mandatory=$false)]
    [String]$version
)
if (-Not $PSBoundParameters.ContainsKey('version')) {
    $version = "latest"
}
Write-Host "Downloading version $version"

$filename = "argocd.exe"
if (Test-Path $filename){
    Write-Host "$filename already exists"    
    return;
}

Invoke-WebRequest -Uri "https://github.com/argoproj/argo-cd/releases/download/$version/argocd-windows-amd64.exe" -OutFile $filename
Write-Host "$filename downloaded. When executing you might get access denied for some reason. Wait a minute and it seems to sort itself out."