param(
    [parameter(Mandatory=$false,
        HelpMessage="The git reference")]
    [String]$ref = 'refs/heads/master'
)

$params = @{
    Body = "
        { 
            ""repository"": { 
                ""git_url"": ""git://github.com/Fresa/argo-continues-delivery-demo.git"" 
            }, 
            ""ref"": ""$ref"", 
            ""commits"": [
                {
                    ""id"": ""d3252721a18cd901dce78147de6b06045cf1aa55"",
                    ""tree_id"": ""58234a96fddb84c8690cf2e59adfbe6e29ad0ca6"",
                    ""distinct"": true,
                    ""message"": ""update readme"",
                    ""timestamp"": ""2020-05-19T14:41:15+02:00"",
                    ""url"": ""https://github.com/Fresa/AppveyorTest/commit/d3252721a18cd901dce78147de6b06045cf1aa55"",
                    ""author"": {
                        ""name"": ""Fredrik Arvidsson"",
                        ""email"": ""fredrik@fkan.se""
                    },
                    ""committer"": {
                        ""name"": ""Fredrik Arvidsson"",
                        ""email"": ""fredrik@fkan.se""
                    },
                    ""added"": [
                
                    ],
                    ""removed"": [
                
                    ],
                    ""modified"": [
                        ""README.md""
                    ]
                }, 
                {
                    ""id"": ""0baa0106436fba975f2414ea3666e0f743ce4e92"",
                    ""tree_id"": ""942a2ebe8980a64c9fd2a423b6f63804609c3bea"",
                    ""distinct"": true,
                    ""message"": ""remove update of readme"",
                    ""timestamp"": ""2020-05-19T14:41:30+02:00"",
                    ""url"": ""https://github.com/Fresa/AppveyorTest/commit/0baa0106436fba975f2414ea3666e0f743ce4e92"",
                    ""author"": {
                        ""name"": ""Fredrik Arvidsson"",
                        ""email"": ""fredrik@fkan.se""
                    },
                    ""committer"": {
                        ""name"": ""Fredrik Arvidsson"",
                        ""email"": ""fredrik@fkan.se""
                    },
                    ""added"": [
                
                    ],
                    ""removed"": [
                
                    ],
                    ""modified"": [
                        ""README.md""
                    ]
                }
            ] 
        }"
    Method = "POST"
    Headers = @{ 
        'Content-Type' = 'application/json'
     }
}

Invoke-WebRequest http://localhost:12000/pushed @params