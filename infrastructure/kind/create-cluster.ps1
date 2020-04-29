param(
    [parameter(Mandatory=$true,
        HelpMessage="The name of the cluster")]
    [String]$name
)

kind create cluster --name $name