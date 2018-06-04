#Any double Write-Output is for the sake of writing to the .txt log and to the powershell console

Add-PSSnapin VeeamPSSnapin

filter timestamp {"$(Get-Date -Format G): $_"}
#checks to see if logfile exists
$logName = "C:\Backup\$(get-date -f yyyy-MM-dd).txt"
If (Test-Path -Path $logname) {
    #already exists
    Write-Output "$logname exists"
} Else {
    #creates one with this content $text at top
    Write-Output "$logname does NOT exist"
    $text = "Veeam Task Scheduled Backup Logs"
    $text | Out-File $logName
}

#function that takes the array of VMs and triggers a VM backup for each.
#the reason for the delay is to keep from overloading the server with backup jobs.
function runBackup($VMS,$delay=180){
    Write-Output "Will backup $VMS"
    Write-Output "Will backup $VMS" >> $logName
    foreach ($vm in $VMs){
        filter timestamp {"$(Get-Date -Format G): $_"}
	    Find-VBRHvEntity -Server 127.0.0.1 -Name $vm | Start-VBRZip -Folder "\\libraryofossus\Veeam Auto" -RunAsync -Compression 6 -AutoDelete In3Months
        Write-Output "Backing up $vm" | timestamp >> $logName
        Start-Sleep -s $delay
    }

}

#Gets the day of the week and runs through an if-elseif-else statement
#to create the appropriate array of VMs to backup for each day of the week
$day = (Get-Date).DayOfWeek
Write-Output "Today is $day"
Write-Output "Today is $day" >> $logName
if($day -eq "Sunday"){
    $VMs = "AELC Child Domain Controller","Backup Domain","CrashPlan Backups","Extra DNS","OfficeServer2","QuickBooks Server","Remote Utilities Server","SMCH - Fog","SMCH - Print Server","Soft Ether","SW Remote Collector","WSUS Server","Xibo - Ubuntu"
    runBackup($VMs)
}ElseIf($day -eq "Monday"){ 
    $VMs = @("OfficeServer2")
    runBackup($VMs,0)
}ElseIf($day -eq "Tuesday"){
    $VMs = @("OfficeServer2")
    runBackup($VMs,0)
}ElseIf($day -eq "Wednesday"){
    $VMs = "AELC Child Domain Controller","Backup Domain","Extra DNS","OfficeServer2"
    runBackup($VMs)
}ElseIf($day -eq "Thursday"){
    $VMs = @("OfficeServer2")
    runBackup($VMs,0)
}ElseIf($day -eq "Friday"){
    $VMs = @("OfficeServer2")
    runBackup($VMs,0)
}ElseIf($day -eq "Saturday"){
    $VMs = @("OfficeServer2")
    runBackup($VMs,0)
}Else{
    #if the day doesn't work, backing up all VMs to be safe
    $VMs = Get-VM
    $list = @()
    foreach($VM in $VMs){
        $list += $VM.Name
    }
    runBackup($VMs,20)
    Write-Output "Today's Day didn't work, so backing them all up"
    Write-Output "Today's Day didn't work, so backing them all up, better safe than sorry" >> $logName
}
