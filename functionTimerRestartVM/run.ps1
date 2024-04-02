# Input bindings are passed in via param block.
param($Timer)

$Subscriptions = Get-AzSubscription -TenantId $tenantId | Where-Object { $_.Name -like "hov-sub*" } | select Id, Name
$date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"GMT Standard Time")

foreach ($Subscription in $Subscriptions) {
	Set-AzContext -Subscription $Subscription.Id
	foreach ($vm in get-azvm -status | Where-Object {($_.Tags.RestartTime -ne $null)}) {
        $now = $date
        if (($vm.PowerState -eq 'VM running') -and ($now -gt $(get-date $($vm.tags.RestartTime))) -and ($now -lt $(get-date $($vm.tags.RestartTime)).Addminutes(10))) {
            #Restart-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -NoWait
            Write-output "Restarting VM - $($vm.Name)"
        }
	}
}
