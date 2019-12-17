$localPath = split-path -parent $MyInvocation.MyCommand.Definition
$user = Read-Host "Please enter user AE Title"
$bucket = Read-Host "Please enter bucket"
$dir = Read-Host "Please enter directory path"

$TaskName = "Pacs Images Download Service"
$TaskDescr = "Pacs Images Download Service"
$TaskCommand = "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
$TaskScript = "$localPath\louncher.ps1"
$TaskArg = "-WindowStyle Hidden -NonInteractive -Executionpolicy unrestricted -file $TaskScript -user $user -bucket $bucket -dir $dir"
$TaskStartTime = [datetime]::Now.AddMinutes(1) 
$service = new-object -ComObject("Schedule.Service")
$service.Connect()
$rootFolder = $service.GetFolder("\")
 
$TaskDefinition = $service.NewTask(0) 
$TaskDefinition.RegistrationInfo.Description = "$TaskDescr"
$TaskDefinition.Settings.Enabled = $true
$TaskDefinition.Settings.AllowDemandStart = $true

 
$triggers = $TaskDefinition.Triggers
$trigger = $triggers.Create(2) 
$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
$trigger.Enabled = $true
$trigger.Repetition.Interval="PT1M"
$trigger.Repetition.StopAtDurationEnd=$false

$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
$action.Arguments = "$TaskArg"

$rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5)  > $null

 write-output "Task successfuly created"