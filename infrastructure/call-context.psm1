class CallContext 
{
    static [string] GetFrom([Object] $instance, [int]$stackLevel = 1){
        return "$($instance.GetType().Name).$((Get-PSCallStack)[$stackLevel].FunctionName)"
    }

    static [string] GetFrom([Type] $type, [int]$stackLevel = 1){
        return [CallContext]::GetFrom($type.Name, $stackLevel)
    }

    static [string] GetFrom([string] $typeName, [int]$stackLevel = 1){
        return "$typeName.$((Get-PSCallStack)[$stackLevel].FunctionName)"
    }    
}