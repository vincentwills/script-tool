$repoZip = "https://github.com/vincentwills/script-tool/archive/refs/heads/main.zip"
$dest = "C:\Scripts"
$temp = "$env:TEMP\repo_download.zip"
$extractTemp = "$env:TEMP\repo_extract"

Invoke-WebRequest -Uri $repoZip -OutFile $temp -UseBasicParsing
if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force }
Expand-Archive -Path $temp -DestinationPath $extractTemp -Force

if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force }
Expand-Archive -Path $temp -DestinationPath $extractTemp -Force

$scriptsSource = Get-ChildItem -Path $extractTemp -Directory | Select-Object -First 1
$scriptsPath = Join-Path $scriptsSource.FullName "Scripts"

if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Move-Item -Path $scriptsPath -Destination $dest -Force

$acl = Get-Acl $dest
$sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $sid, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.SetAccessRule($rule)
Set-Acl $dest $acl

Remove-Item $temp -Force
Remove-Item $extractTemp -Recurse -Force

$action = New-ScheduledTaskAction -Execute "wscript.exe" ` -Argument '"C:\Scripts\run_hidden.vbs"'
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-545" -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "ScriptPack" ` -Action $action -Trigger $trigger -Principal $principal -Settings $settings ` -Description "Executes the scripts without a popup window"
