Using module ".\call-context.psm1"

class Log
{
    [Type] $Class

    Log([Type] $class)
    {
        $this.Class = $class
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
        return "[$(Get-Date -Format ""HH:mm:ss"")] [$([CallContext]::GetFrom($($this.Class), 3))] $message"
    }
}