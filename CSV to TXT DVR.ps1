$FilePath = (New-Object -ComObject Shell.Application).BrowseForFolder(0, "Select CSV File", 0).Self.Path
if (-not $FilePath) { exit }

$CsvFile = Get-ChildItem -Path $FilePath -Filter "*.csv" | Select-Object -First 1
if (-not $CsvFile) { Write-Host "No CSV file selected."; exit }

# Import CSV
$Data = Import-Csv -Path $CsvFile.FullName

# Get column names
$ColumnNames = $Data[0].PSObject.Properties.Name

# Check if J and U exist by name
$ColJ = $ColumnNames[9]  # 10th column (J)
$ColU = $ColumnNames[20] # 21st column (U)

# Select only columns J and U using detected names
$SelectedData = $Data | Select-Object -Property $ColJ, $ColU

# Process timestamp (column J)
$Output = $SelectedData | ForEach-Object {
    $Timestamp = $_.$ColJ -replace ":\d{2}$", ""  # Remove last :XX
    $Timestamp = $Timestamp -replace "^00:", ""  # Remove leading 00: if present
    $Description = $_.$ColU
    "{0}`t{1}" -f $Timestamp, $Description
}

# Save as Text File
$TxtPath = $CsvFile.FullName -replace ".csv$", ".txt"
$Output | Out-File -FilePath $TxtPath -Encoding UTF8

Write-Host "File saved as $TxtPath"