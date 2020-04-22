class Port
{
	static [void]Forward($Service, $Namespace, $From, $To) 
	{
		$jobName = "$($Service)PortForward"
		$command = "kubectl port-forward $Service $($From):$($To) --namespace $($Namespace)"		
		Start-Job -Name $jobName -InputObject $command -ScriptBlock { 
			Invoke-Expression $input
		}
		Receive-Job $jobName
		Write-Host "Service $Service in namespace $Namespace now available at 127.0.0.1:$From"
	}
}