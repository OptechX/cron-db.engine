<# VARIABLES #>
[System.String]$LONG_RECORD_OUTPUT = "${PSScriptRoot}/long-record-output.txt"
$OFS = ', '

<# PRE-PROCESSING #>
if (Test-Path -Path $LONG_RECORD_OUTPUT) { Remove-Item -Path $LONG_RECORD_OUTPUT -Force -Confirm:$false }
$json = Get-Content -Path $PSScriptRoot/lib/windows_index.json | ConvertFrom-Json

<# CLASSES #>
class WindowsCoreIdentity {
    [System.Int16]$id = 0
    [System.Guid]$uuid = [System.Guid]::NewGuid()
    [System.String]$uid             # 
    [System.String]$release         # Windows 10
    [System.String]$edition         # Enterprise/LTSC
    [System.String]$version         # 21H2
    [System.String]$build           # 190444
    [System.String]$arch            # x64
    [System.String]$windowsLcid     # MUI
    [System.String]$supportedUntil  # 2022-10-23
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
            $lcid = $json.$k.$r.$e.'LANG'
            $cpuarch = $json.$k.$r.$e.'ARCH'
            [System.String]$gciLcid = ""
            switch($lcid.Count)
            {
                { $_ -eq 1 } {
                    $gciLcid = "en-US"
                }
                { $_ -gt 1 } {
                    $gciLcid = "en-US,MUI"
                }
            }

            $wci = [WindowsCoreIdentity]::new()
            $wci.release = $k
            $wci.edition = $e
            $wci.version = $r
            $wci.build = $json.$k.$r.$e.'BUILD'
            $wci.arch = "$cpuarch"
            $wci.windowsLcid = "$lcid"
            $wci.supportedUntil = $json.$k.$r.$e.'EOL'.ToString()
            $uid = $wci.release + '.' `
                    + $wci.edition + '.' `
                    + $wci.version + '.' `
                    + $wci.build + '.' `
                    + "$cpuarch".ToString() + '.' `
                    + $gciLcid
            $uid = $uid.Replace(' ','').Replace(',','').ToLower().Replace("en-usmui","en-us_mui")
            $wci.uid = $uid
            $body = $wci | ConvertTo-Json
            $body
            Invoke-RestMethod -Uri "https://engine.api.prod.optechx-data.com/v1/WindowsCoreIdentity" -Method Post -UseBasicParsing -Body $body -Header @{"Accept" = "application/json"} -ContentType "application/json"


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