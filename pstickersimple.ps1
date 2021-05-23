#https://superuser.com/questions/1467105/how-can-i-add-a-folder-toolbar-to-windows-10-taskbar-with-powershell
# per aggiungere toolbar automaticamente


param (
	[string][Alias('s')]$security="GME",
	[string][Alias('r')]$refresh=3
)

$url = "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com&symbols=" + $security
$arrow_up = "$([char]0x25b2)"
$arrow_down = "$([char]0x25bc)" 
$out_color = ""

while ($true){
	
    $d = (New-Object Net.Webclient).DownloadString($url) | ConvertFrom-Json
	$d = $d.quoteResponse.result
	
	#$d
    #start-sleep 1000
	
    $rmp = $d.regularMarketPrice
	$rmp = [math]::Round($rmp,2)
	
    $symbol = $d.symbol
	
	$prev_close = $d.regularMarketPreviousClose
	
	$change_prc = $d.regularMarketChangePercent
	$change_prc = [math]::Round($change_prc,2)
	
	if ($rmp -ge $prev_close) {
		$out = $arrow_up + " " + $symbol + ": " + $rmp
		$out_color = "green"
	} else {
		$out = $arrow_down + " " + $symbol + ": " + $rmp
		$out_color = "red"
	}
	
	clear-host
	write-host -ForegroundColor $out_color $out
	write-host -ForegroundColor $out_color " "$change_prc"%"
	
    Start-Sleep -Seconds $refresh
}
