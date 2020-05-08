Using module ".\call-context.psm1"

class Log
{
    [string] $ClassName

    Log([Type] $class)
    {
        $this.ClassName = $class.Name
    }

    Log([string] $className)
    {
        $this.ClassName = $className
    }

    [void] Info([string]$message)
    {
        Write-Host $this.GetLogMessage($message)
    }

    [void] Info([string]$message, [System.ConsoleColor]$foregroundColor)
    {
        Write-Host $this.GetLogMessage($message) -ForegroundColor $foregroundColor
    }

    [void] Warning([string]$message)
    {
        Write-Warning $this.GetLogMessage($message)
    }

    [void] Error([string]$message)
    {
        Write-Host "ERROR: $($this.GetLogMessage($message))" -ForegroundColor Red -BackgroundColor Black
    }

    [string] GetLogMessage([string]$message)
    {
        return "[$(Get-Date -Format ""HH:mm:ss"")] [$([CallContext]::GetFrom($($this.ClassName), 3))] $message"
    }
}