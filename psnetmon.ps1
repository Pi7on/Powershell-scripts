#Author: https://github.com/Pi7on
#Version: 2.1

param ([switch]$help, 
	   [string]$unit="Kb", 
	   [int]$refresh, 
	   [int]$precision=2
)

if($help){
	Write-Host "Parameters:"
	Write-Host "-help:"
	Write-Host "	Display this message."
	Write-Host "-unit <String>:"
	Write-Host "	Available units are:"
	Write-Host "-refresh <int>:"
	Write-Host "	How many milliseconds to sleep before refreshing."
	Write-Host "-precision <int>:"
	Write-Host "	Number of decimal which will be used to display the numbers."
	exit
}

switch ($unit) {
	"b" {$unit_multiplier = 8}
	"Kb" {$unit_multiplier = 8 * [Math]::Pow(10,-3)}
	"Mb" {$unit_multiplier = 8 * [Math]::Pow(10,-6)}
	"Gb" {$unit_multiplier = 8 * [Math]::Pow(10,-9)}
	"Tb" {$unit_multiplier = 8 * [Math]::Pow(10,-12)}
	"Pb" {$unit_multiplier = 8 * [Math]::Pow(10,-15)}
	"Eb" {$unit_multiplier = 8 * [Math]::Pow(10,-18)}
	"Zb" {$unit_multiplier = 8 * [Math]::Pow(10,-21)}
	"Yb" {$unit_multiplier = 8 * [Math]::Pow(10,-24)}
	
	"B" {$unit_multiplier = 1}
	"KB" {$unit_multiplier = [Math]::Pow(10,-3)}
	"MB" {$unit_multiplier = [Math]::Pow(10,-6)}
	"GB" {$unit_multiplier = [Math]::Pow(10,-9)}
	"TB" {$unit_multiplier = [Math]::Pow(10,-12)}
	"PB" {$unit_multiplier = [Math]::Pow(10,-15)}
	"EB" {$unit_multiplier = [Math]::Pow(10,-18)}
	"ZB" {$unit_multiplier = [Math]::Pow(10,-21)}
	"YB" {$unit_multiplier = [Math]::Pow(10,-24)}
	
	
}

if (-not $refresh) {
	$refresh = 1000
}

while(1) {
	$interface = Get-CimInstance -class Win32_PerfRawData_Tcpip_NetworkInterface | select BytesReceivedPersec, BytesSentPersec, Name
	
	$values_current = ($interface.BytesReceivedPersec, $interface.BytesSentPersec)
	
	if($values_prev -ne $null){
	
		$UL_speed = $values_current[1] - $values_prev[1]
		$DL_speed = $values_current[0] - $values_prev[0]
		
		$UL_display_value = [math]::Round(($UL_speed * $unit_multiplier / ($refresh/1000)), $precision)
		$DL_display_value = [math]::Round(($DL_speed * $unit_multiplier / ($refresh/1000)), $precision)
		
		cls	
		Write-Host $interface.name
		Write-Host "U$([char]0x2b06)"$unit"/s "$UL_display_value"`nD$([char]0x2b07) "$unit"/s "$DL_display_value | format-table
		#Write-Host "$([char]0x2191)U:"($UL_speed * $unit_multiplier)$unit"/s`n$([char]0x2193)D:"($DL_speed * $unit_multiplier)$unit"/s"
	}
	$values_prev = $values_current.Clone()
	Start-Sleep -milliseconds $refresh
}
