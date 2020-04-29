param(
    [parameter(Mandatory=$true,
        HelpMessage="The name of the cluster")]
    [String]$name
)

kind delete cluster --name $name