<# VARIABLES #>
[System.String]$LONG_RECORD_OUTPUT = "${PSScriptRoot}/long-record-output.txt"

<# PRE-PROCESSING #>
if (Test-Path -Path $LONG_RECORD_OUTPUT) { Remove-Item -Path $LONG_RECORD_OUTPUT -Force -Confirm:$false }
$json = Get-Content -Path $PSScriptRoot/lib/windows_index.json | ConvertFrom-Json

<# CLASSES #>
class WindowsCoreIdentity {
    [System.Int16]$id = 0
    [System.Guid]$uuid = [System.Guid]::NewGuid()
    [System.String]$uid
    [System.String]$release
    [System.String]$edition
    [System.String]$version
    [System.String]$build
    [System.String]$arch
    [System.String]$windowsLcid
    [System.String]$supportedUntil
}

$KEYS = $json.WINDOWS_LIST

foreach ($k in $KEYS)
{
    "${k}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
    $RELEASE = $json.$k.'RELEASE'
    foreach ($r in $RELEASE)
    {
        "  - ${r}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
        $EDITION = $json.$k.$r.'EDITION'
        foreach ($e in $EDITION)
        {
            <# CREATE THE OBJECT HERE#>
            "    - ${e}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
            $ARCH = $json.$k.$r.$e.'ARCH'
            foreach ($a in $ARCH)
            {
                "      - ${a}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
                $EOL = $json.$k.$r.$e.'EOL'
                $BUILD = $json.$k.$r.$e.'BUILD'
                $LANG = $json.$k.$r.$e.'LANG'
                foreach ($l in $LANG)
                {
                    "        - ${l}" | Out-File -FilePath $LONG_RECORD_OUTPUT -Append
                }
            }
        }
    }
}



# #region Windows 10
# [System.String]$KEY = "Windows 10"
# $DATA = $json.$KEY
# $RELEASE = $DATA.'RELEASE'

# <# WRITE LONG RECORD #>


# <# PROCESS WINDOWS IMAGE #>
# # foreach ($r in $RELEASE)
# # {
# #     <# api:version->$r (ie 21H2) #>
# #     foreach ($e in $DATA.$r.'EDITION')
# #     {
# #         <# api:edition->$e.Split(',') (ie Professional/Pro)#>
# #         foreach ($a in $DATA.$r.$e.'ARCH')
# #         {
# #             Write-Output "Downloading: ${KEY} ${r} ${e} ${a} - English"
# #             if ($IsWindows) { $URL = & "$PSScriptRoot\Fido\Fido.ps1" -Win "$KEY" -Rel "$r" -Ed "$e" -Lang "English" -Arch "$a" -GetUrl }
# #             else { $URL = & "$PSScriptRoot/Fido/Fido.ps1" -Win "$KEY" -Rel "$r" -Ed "$e" -Lang "English" -Arch "$a" -GetUrl }
# #             "$URL"
# #             $FILE = Split-Path -Path $URL.Split('?')[0] -Leaf
# #             $FILE
# #             # Invoke-WebRequest -Uri $URL -OutFile "./data/${FILE}" -UseBasicParsing -SslProtocol Tls13 -Method Get -ContentType "application/json"
# #             Pause
# #         }
# #     }
# # }
# #endregion Windows 10