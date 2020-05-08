Using module ".\log.psm1"

class Port
{
	static [Log] $Log = [Log]::new([Port])

	static [void]Forward(
		[string]$resource, 
		[string]$namespace, 
		[int]$from, 
		[int]$to, 
		[int]$timeoutInSeconds
	) 
	{
		$currentContext = Invoke-Expression "kubectl config current-context"
		[Port]::Log.Info("Waiting max $($timeoutInSeconds)s for $resource in namespace $namespace and context $currentContext to become available for port forwarding...")

		$jobName = "$($resource)PortForward"
		$command = "kubectl port-forward --pod-running-timeout=$($timeoutInSeconds)s $resource $($from):$($to) --namespace $($namespace)"
		$originalCall = "[Port]::Forward(""$resource"", ""$namespace"", $from, $to, $timeoutInSeconds)"
		Start-Job -Name $jobName -ScriptBlock { 
			param($command, $originalCall, $timeoutInSeconds, $logModulePath)
			Import-Module $logModulePath
			$log = & (Get-Module Log) { [Log]::new("Port.Forward") }
			
			$wait = New-TimeSpan -Seconds $timeoutInSeconds
			$stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
			$stopWatch.Start()
	
			$restartWaitInSeconds = 1
			Invoke-Expression $command

			$retries = 0
			while ($stopWatch.Elapsed -le $wait)
			{
				$retries++
				$log.Info("[$retries] Restarting ""$command"" in $($restartWaitInSeconds)s")
				Start-Sleep -Seconds $restartWaitInSeconds
	
				Invoke-Expression $command
			}

			$log.Error("Port forward timed out ($($stopWatch.Elapsed.ToString('mm\m\ ss\s'))), giving up")
			$log.Info("To port forward again run:")
			$log.Info($originalCall)
		} -ArgumentList $command, $originalCall, $timeoutInSeconds, "$(Get-Location)\log.psm1"

		[Port]::Log.Info("Resource $resource in namespace $namespace should soon be available at 127.0.0.1:$from")
		[Port]::Log.Info("Call ""Receive-Job -Name $jobName"" to get more info")
	}

	static [void]Stop(
		[string]$resource
	) 
	{
		[Port]::Log.Info("Stopping port forwarding for Resource $resource...")
		$jobName = [Port]::GetJobName($resource)
        if ([bool] (Get-Job -Name $jobName -ea silentlycontinue))
		{
            Stop-Job -name $jobName
            Remove-Job -name $jobName
            [Port]::Log.Info("Port forwarding for rersource $resource has stopped")
		} 
		else
        {
            [Port]::Log.Warning("Could not stop $jobName, the job was not found")
        }		
	}

	static [bool] TryWaitUntilAvailable(
		[string]$url
	)
	{
        $wait = New-TimeSpan -Minutes 2
        $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
        $stopWatch.Start()

		[Port]::Log.Info("Waiting for $url to return status code 200 within $($wait.ToString('mm\m\:ss\s'))")
        $errorRecord = $null
		while ($stopWatch.Elapsed -le $wait)
		{
			try 
			{
                $response = wget $url
				if ($response.StatusCode -eq 200)
				{
                    [Port]::Log.Info("$url is responding", [ConsoleColor]::Green)
                    return $true
                }
                [Port]::Log.Warning("$url responded with status code: $($response.StatusCode)")
			} 
			catch 
			{ 
				$errorRecord = $_ 
			}
            Start-Sleep -Seconds 1
        }         
		
		[Port]::Log.Error("Waited $($stopWatch.Elapsed.ToString('mm\m\ ss\s')) for $url to become reachable, giving up")
		if ($errorRecord -ne $null)
		{
			[Port]::Log.Error("Last error recorded:")
			[Port]::Log.Error("$($errorRecord | out-string)")
		}
		return $false
	}
	
	static [void] OutputInfo(
		[string]$resource
	)
	{
		$jobName = [Port]::GetJobName($resource)
		if ([bool] (Get-Job -Name $jobName -ea silentlycontinue))
		{
			[Port]::Log.Info("Printing output from job $jobName below", [ConsoleColor]::Cyan)
			[Port]::Log.Info("BEGIN $("=" * 40) BEGIN", [ConsoleColor]::Cyan)
			Receive-Job -Name $jobName
			[Port]::Log.Info("END $("=" * 40) END", [ConsoleColor]::Cyan)
		}
		else 
		{
			[Port]::Log.Warning("Could not get info about job $jobName, the job was not found")
		}
	}

	static [string] GetJobName(
		[string]$resource
	)
	{
		return "$($resource)PortForward"
	}
}