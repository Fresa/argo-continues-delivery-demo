class Port
{
	static [void]Forward($Service, $Namespace, $From, $To) 
	{
		$jobName = "$($Service)PortForward"
		$command = "kubectl port-forward $Service $($From):$($To) --namespace $($Namespace)"		
		Start-Job -Name $jobName -InputObject $command -ScriptBlock { 
			Invoke-Expression $input
		}
		Receive-Job $jobName -Keep
		Write-Host "Service $Service in namespace $Namespace now available at 127.0.0.1:$From"
	}

	static [void]Stop($Service) 
	{
		Write-Host "Stopping port forwarding for service $Service..."
		$jobName = "$($Service)PortForward"
		Get-Job -name "$jobName*" | Stop-Job
		Get-Job -name "$jobName*" | Remove-Job
		Write-Host "Port forwarding for service $Service has stopped"
	}
}