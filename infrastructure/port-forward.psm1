Using module ".\log.psm1"

class PortForward
{
	[Log] $Log = [Log]::new([PortForward])

	[string]$Resource
	[string]$JobName
	[string]$Namespace
	[int]$From
	[int]$To

	PortForward(
		[string]$resource, 
		[string]$namespace,
		[int]$from, 
		[int]$to)
	{
		$this.Resource = $resource
		$this.Namespace = $namespace
		$this.From = $from
		$this.To = $to
		$this.JobName = "$($this.Resource)PortForward"
	}

	[void]Start(
		[int]$timeoutInSeconds
	) 
	{
		$currentContext = Invoke-Expression "kubectl config current-context"
		$this.Log.Info("Waiting max $($timeoutInSeconds)s for $($this.Resource) in namespace $($this.Namespace) and context $currentContext to become available for port forwarding...")

		$command = "kubectl port-forward --pod-running-timeout=$($timeoutInSeconds)s $($this.Resource) $($this.From):$($this.To) --namespace $($this.Namespace)"
		$originalCall = "\`$<portForward>.$((Get-PSCallStack)[0].FunctionName)($timeoutInSeconds)"
		Start-Job -Name $this.JobName -ScriptBlock { 
			param($command, $originalCall, $timeoutInSeconds, $logModulePath)
			Import-Module $logModulePath
			$log = & (Get-Module Log) { [Log]::new("PortForward.Run") }
			
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

		$this.Log.Info("Resource $($this.Resource) in namespace $($this.Namespace) should soon be available at 127.0.0.1:$($this.From)")
		$this.Log.Info("Call ""Receive-Job -Name $($this.JobName)"" to get more info")
	}

	[void]Stop() 
	{
		$this.Log.Info("Stopping port forwarding for Resource $($this.Resource)...")
		if ([bool] (Get-Job -Name $this.JobName -ea silentlycontinue))
		{
            Stop-Job -name $this.JobName
            Remove-Job -name $this.JobName
            $this.Log.Info("Port forwarding for rersource $($this.Resource) has stopped")
		} 
		else
        {
            $this.Log.Warning("Could not stop $($this.JobName), the job was not found")
        }		
	}

	[bool] TryWaitUntilAvailable(
		[string]$url
	)
	{
        $wait = New-TimeSpan -Minutes 2
        $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
        $stopWatch.Start()

		$this.Log.Info("Waiting for $url ($($this.Resource)) to return status code 200 within $($wait.ToString('mm\m\:ss\s'))")
        $errorRecord = $null
		while ($stopWatch.Elapsed -le $wait)
		{
			try 
			{
                $response = wget $url
				if ($response.StatusCode -eq 200)
				{
                    $this.Log.Info("$url is responding", [ConsoleColor]::Green)
                    return $true
                }
                $this.Log.Warning("$url responded with status code: $($response.StatusCode)")
			} 
			catch 
			{ 
				$errorRecord = $_ 
			}
            Start-Sleep -Seconds 1
        }         
		
		$this.Log.Error("Waited $($stopWatch.Elapsed.ToString('mm\m\ ss\s')) for $url ($($this.Resource)) to become reachable, giving up")
		if ($errorRecord -ne $null)
		{
			$this.Log.Error("Last error recorded:")
			$this.Log.Error("$($errorRecord | out-string)")
		}
		return $false
	}
	
	[void] OutputInfo()
	{
		if ([bool] (Get-Job -Name $($this.JobName) -ea silentlycontinue))
		{
			$this.Log.Info("Printing output from job $($this.JobName) below", [ConsoleColor]::Cyan)
			$this.Log.Info("BEGIN $("=" * 40) BEGIN", [ConsoleColor]::Cyan)
			Receive-Job -Name $this.JobName
			$this.Log.Info("END $("=" * 40) END", [ConsoleColor]::Cyan)
		}
		else 
		{
			$this.Log.Warning("Could not get info about job $($this.JobName), the job was not found")
		}
	}
}