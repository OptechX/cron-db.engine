<# VARIABLES #>
[System.String]$LONG_RECORD_OUTPUT = "${PSScriptRoot}/long-record-output.txt"
[System.String]$BASE_URI = "https://engine.api.prod.optechx-data.com"
$OFS = ', '

<# PRE-PROCESSING #>
if (Test-Path -Path $LONG_RECORD_OUTPUT) { Remove-Item -Path $LONG_RECORD_OUTPUT -Force -Confirm:$false }
$json = Get-Content -Path $PSScriptRoot/lib/windows_index.json | ConvertFrom-Json

<# CLASSES #>
class WindowsCoreIdentity {
    [System.Int16]$id = 0
    [System.Guid]$uuid = [System.Guid]::NewGuid()
    [System.String]$uid
    [System.String]$release              # Windows 10
    [System.String]$edition              # Enterprise/LTSC
    [System.String]$version              # 21H2
    [System.String]$build                # 190444
    [System.String]$arch                 # x64
    [System.String]$windowsLcid          # MUI
    [System.String]$supportedUntil       # 2022-10-23
    [System.String[]]$suportedLanguages  # ar,en-INTL,en,pl
}

<# LANGUAGE STRUCT #>
. $PSScriptRoot\lang_struct.ps1

<# KEYS #>
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
                    $gciLcid = "en-US, MUI"
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

            try {
                Invoke-RestMethod -Uri "${BASE_URI}/v1/WindowsCoreIdentity/uid/${uid}" -Method Get -Headers @{"Accept" = "application/json"} -ErrorAction Stop
            }
            catch {
                Invoke-RestMethod -Uri "${BASE_URI}/v1/WindowsCoreIdentity" -Method Post -UseBasicParsing -Body $body -Header @{"Accept" = "application/json"} -ContentType "application/json"
            }

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
