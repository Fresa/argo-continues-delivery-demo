$clusters = @("argo-demo-ci", "argo-demo-test", "argo-demo-prod")
$contexts = $clusters | Foreach-Object {"kind-$_"}