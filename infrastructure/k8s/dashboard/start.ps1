Start-Job -Name KubernetesProxy -ScriptBlock { kubectl proxy }
Receive-Job KubernetesProxy
Write-Host "Dashboard available at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"