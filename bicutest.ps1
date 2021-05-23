#version: 1.1

param (
	[switch][Alias("skip")]$skip_processing,
	[string][Alias("i","input")]$input_frame,
	[Parameter(Mandatory=$true)][int][Alias("r","resolution")]$assumed_native_resolution #mandatory because even if getnative processing is skipped, we still need it to filter the txt files
)

$testres_max = $assumed_native_resolution
$testres_min = $assumed_native_resolution-1

if(-not $skip_processing){
	for ($b = 0; $b -le 100; $b += 1){
		for($c =100 ; $c -ge 0; $c -= 1){
			$b_ = $b/100
			$c_ = $c/100
			write-host "b=" $b_ " c=" $c_
			getnative --kernel bicubic --bicubic-b $b_ --bicubic-c $c_ --min-height $testres_min --max-height $testres_max $input_frame > $null
		}
	}
}

#find errors in generated txt files
$patt = "^ "+$testres_max
$lines = Select-String -Path "results\*.txt" -Pattern $patt

#write csv
write-host "saving csv..."
foreach ($line in $lines){
	$line.tostring().replace("| ","").replace("`t","").replace(" ",",") >> ".\results.csv"
}
write-host "  Done"

#make arraylist of errors
$errors = New-Object -TypeName "System.Collections.ArrayList"
foreach ($line in $lines) {
	$err = $line.tostring().Split("|")[1]
	$ferr = [double]$err
	[void]$errors.Add($ferr) #[void] is to stop this from printig the array index every time
}

#sort in crescent order and grab lowest 10
$ten_lowest_errors = $errors | Sort-Object -unique | select -First 10
write-host ""

#save to file
write-host "Saving ten lowest errors..."
$filename = (get-date -format "MM_dd_yy--hh_mm_ss")+"--"+$input_frame+".txt"

$i = 0
foreach ($val in $ten_lowest_errors){
	$search = $val.tostring("0.0000000000").replace(",",".")
	$current_result = Select-String -Path "results\*.txt" -Pattern $search
	foreach ($possible_dup in $current_result){
		$pd = $possible_dup.tostring().replace("| ","").replace("`t","")
		"  "+$i+". "+$pd >> $filename
		write-host "  "$i". "$pd
	}
	write-host ""
	$i++
}
write-host "  Done."


