param(
    [parameter(Mandatory=$true,
        HelpMessage="Example: 2.7.5. Releases: https://github.com/argoproj/argo/releases")]
    [String]$version
)

Write-Host "Downloading version $version"

$filename = "argo.exe"
if (Test-Path $filename){
    Write-Host "$filename already exists"    
    return;
}

Invoke-WebRequest -Uri "https://github.com/argoproj/argo/releases/download/v$version/argo-windows-amd64" -OutFile $filename
Write-Host "$filename downloaded."