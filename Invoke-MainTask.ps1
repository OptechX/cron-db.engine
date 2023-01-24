<# VARIABLES #>
[System.String]$LONG_RECORD_OUTPUT = "${PSScriptRoot}/long-record-output.txt"

<# PRE-PROCESSING #>
if (Test-Path -Path $LONG_RECORD_OUTPUT) { Remove-Item -Path $LONG_RECORD_OUTPUT -Force -Confirm:$false }
$json = Get-Content -Path $PSScriptRoot/lib/windows_index.json | ConvertFrom-Json

#region Windows 10
[System.String]$KEY = "Windows 10"
$DATA = $json.$KEY
$RELEASE = $DATA.'RELEASE'

<# WRITE LONG RECORD #>
foreach ($r in $RELEASE)
{
    <# api:version->$r #>
    "${KEY} ${r}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
    $EDITION = $DATA.$r.'EDITION'
    foreach ($e in $EDITION)
    {
        "  - ${e}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
        foreach ($ARCH in $DATA.$r.$e.'Arch')
        {
            "    - ${ARCH}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
            foreach ($LANG in $DATA.$r.$e.'Lang')
            {
                "      - ${LANG}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
            }
        }
    }
}

<# PROCESS WINDOWS IMAGE #>
# foreach ($r in $RELEASE)
# {
#     <# api:version->$r (ie 21H2) #>
#     foreach ($e in $DATA.$r.'EDITION')
#     {
#         <# api:edition->$e.Split(',') (ie Professional/Pro)#>
#         foreach ($a in $DATA.$r.$e.'ARCH')
#         {
#             Write-Output "Downloading: ${KEY} ${r} ${e} ${a} - English"
#             if ($IsWindows) { $URL = & "$PSScriptRoot\Fido\Fido.ps1" -Win "$KEY" -Rel "$r" -Ed "$e" -Lang "English" -Arch "$a" -GetUrl }
#             else { $URL = & "$PSScriptRoot/Fido/Fido.ps1" -Win "$KEY" -Rel "$r" -Ed "$e" -Lang "English" -Arch "$a" -GetUrl }
#             "$URL"
#             $FILE = Split-Path -Path $URL.Split('?')[0] -Leaf
#             $FILE
#             # Invoke-WebRequest -Uri $URL -OutFile "./data/${FILE}" -UseBasicParsing -SslProtocol Tls13 -Method Get -ContentType "application/json"
#             Pause
#         }
#     }
# }
#endregion Windows 10