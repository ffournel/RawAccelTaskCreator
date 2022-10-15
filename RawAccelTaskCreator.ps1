#"if No Administrative rights at launch, it will ask user for Admin rights while keeping keeping location"
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments

break
}

function Show-Menu {
    param (
        [string]$Title = 'Raw Accel Startup Task Creator'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Enter '1' for creating a new task on starup for Raw Accel."
    Write-Host "2: Enter '2' for deleting an existing registered Raw Accel Startup Task."
    Write-Host "q: Enter 'q' to quit."
}
#"Task parameters"
$taskName = "Raw Accel Task"
$description = "Task runner for Raw Accel on Windows at user log-in"
$taskAction = New-ScheduledTaskAction `
        -Execute $PSScriptRoot\writer.exe `
        -Argument $PSScriptRoot\settings.json
$taskAction
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
$taskPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

do
{
Show-Menu
$selection = Read-Host "Please select an option"
switch ($selection)
 {
     '1' { 
            Register-ScheduledTask `
                -TaskName $taskName `
                -Description $description `
                -Action $taskAction `
                -Trigger $taskTrigger `
                -Principal $taskPrincipal
         'You chose to create a new Raw Accel Startup Task'
     } '2' {
          Unregister-ScheduledTask -TaskName $taskName -Confirm:$False
         'You chose to remove an existing registered Raw Accel Startup Task'
     } 'q' {
         return
     }
    }
    pause
}
until ($selection -eq 'q')