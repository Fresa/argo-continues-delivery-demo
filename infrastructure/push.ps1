param(
    [parameter(Mandatory=$false,
        HelpMessage="The commit SHA after the push event")]
    [String]$after = '0f4f7b2125e2b9cb8a5215335fcb14b608613f31'
)

$params = @{
    Body = "{ ""repository"": { ""clone_url"": ""https://github.com/Fresa/argo-continues-delivery-demo.git"" }, ""after"": ""$after"" }"
    Method = "POST"
    Headers = @{ 
        'Content-Type' = 'application/json'
     }
}

Invoke-WebRequest http://localhost:12000/pushed @params