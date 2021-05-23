#save image from clipboard to current working directory

$img = Get-Clipboard -format image
$cwd = Get-Location
$date = Get-Date -Format "yyyyMMdd_HHmm"

$filepath = $cwd.ToString() + "\" + $date.ToString() + ".png"
#$filepath = [System.IO.DirectoryInfo]$filepath

$img.save($filepath)