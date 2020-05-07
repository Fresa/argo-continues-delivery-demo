class CallContext 
{
    static [string] GetFrom([Object] $instance, [int]$stackLevel = 1){
        return "$($instance.GetType().Name).$((Get-PSCallStack)[$stackLevel].FunctionName)"
    }
    static [string] GetFrom([Type] $type, [int]$stackLevel = 1){
        return "$type.$((Get-PSCallStack)[$stackLevel].FunctionName)"
    }
}

class Log
{
    [void] Info([string]$message, [Object] $instance)
    {
        $this.Info($message, $instance.GetType())
    }

    [void] Info([string]$message, [Type] $type)
    {
        Write-Host $this.GetLogMessage($message, $type)
    }

    [void] Warning([string]$message, [Object] $instance)
    {
        $this.Warning($message, $instance.GetType())
    }

    [void] Warning([string]$message, [Type] $type)
    {
        Write-Warning $this.GetLogMessage($message, $type)
    }

    [void] Error([string]$message, [Object] $instance)
    {
        $this.Error($message, $instance.GetType())
    }

    [void] Error([string]$message, [Type] $type)
    {
        Write-Error -Message $this.GetLogMessage($message, $type)
    }

    [string] GetLogMessage([string]$message, [Type] $type)
    {
        return "[$(Get-Date -Format ""HH:mm:ss"")] [$([CallContext]::GetFrom($type, 2))] $message"
    }
}