# Input bindings are passed in via param block.
param($Timer)

$tenant = get-aztenant
$tenantID = $tenant.Id

$Subscriptions = Get-AzSubscription -TenantId $tenantId | select Id, Name
$date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"GMT Standard Time")

foreach ($Subscription in $Subscriptions) {
	Set-AzContext -Subscription $Subscription.Id
    write-output "Looking up VMs in sub $($Subscription.Name)"
	foreach ($vm in get-azvm -status | Where-Object {($_.Tags.RestartTime -ne $null)}) {
        write-output "Checking restart tags for VM $($vm.Name)"
        $now = $date
        if (($vm.PowerState -eq 'VM running') -and ($now -gt $(get-date $($vm.tags.RestartTime))) -and ($now -lt $(get-date $($vm.tags.RestartTime)).Addminutes(10))) {
            #Restart-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -NoWait
            Write-output "Restarting VM - $($vm.Name)"
        }
	}
}
