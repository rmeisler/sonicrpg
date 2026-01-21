$loveSize = (Get-Item "love64.exe").Length
$inputFile = "SonicRPG.exe"
$outputFile = "SonicRPG.love"

$inputStream = [System.IO.File]::OpenRead($inputFile)
$outputStream = [System.IO.File]::Create($outputFile)

# Skip the love64.exe portion
$inputStream.Seek($loveSize, [System.IO.SeekOrigin]::Begin) | Out-Null

# Copy the remaining data
$inputStream.CopyTo($outputStream)

$inputStream.Close()
$outputStream.Close()

Write-Host "Extraction complete! SonicRPG.love created."