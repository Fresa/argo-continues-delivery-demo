param(
    [parameter(Mandatory=$false,
        HelpMessage="The git reference")]
    [String]$ref = 'refs/heads/master'
)

$params = @{
    Body = "{ ""repository"": { ""git_url"": ""git://github.com/Fresa/argo-continues-delivery-demo.git"" }, ""ref"": ""$ref"" }"
    Method = "POST"
    Headers = @{ 
        'Content-Type' = 'application/json'
     }
}

Invoke-WebRequest http://localhost:12000/pushed @params