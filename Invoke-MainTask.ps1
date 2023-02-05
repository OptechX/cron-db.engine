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

<# LOAD LANGUAGE STRUCT #>
. $PSScriptRoot\lang_struct.ps1

<# KEYS #>
$KEYS = $json.WINDOWS_LIST



foreach ($k in $KEYS)
{
  $RELEASE = $json.$k.'RELEASE'
  foreach ($r in $RELEASE)
  {
    $EDITION  = $json.$k.$r.'EDITION'
    foreach ($e in $EDITION)
    {
      $EOL = $json.$k.$r.$e.'EOL'
      $BUILD = $json.$k.$r.$e.'BUILD'

      $arch_list = $json.$k.$r.$e.'ARCH'
      $lang_list = $json.$k.$r.$e.'LANG'

      $cpu = "$arch_list".ToString()

      if ($lang_list.Count -gt 1)
      {
        $winLCID = "en-US, MUI"
      }
      else
      {
        $winLCID = "en-US"
      }

      $lang_array = @()
      foreach ($l in $lang_list)
      {
        $lang_to_add = $langStruct."${l}"
        $lang_array = $lang_array += @($lang_to_add)
      }
          
      $wci = [WindowsCoreIdentity]::new()
      $wci.release = $k
      $wci.edition = $e
      $wci.version = $r
      $wci.build = $BUILD
      $wci.arch = $cpu
      $wci.windowsLcid = $winLCID
      $wci.supportedUntil = $EOL.ToString()
      $uid = $wci.release + '.' `
              + $wci.edition + '.' `
              + $wci.version + '.' `
              + $wci.build + '.' `
              + $cpu + '.' `
              + $winLCID
      $uid = $uid.Replace(' ','').Replace(',','').ToLower().Replace("en-usmui","en-us_mui")
      $wci.uid = $uid
      $wci.suportedLanguages = @($lang_array)
      $body = $wci | ConvertTo-Json
      $body

      try {
        Invoke-RestMethod -Uri "${BASE_URI}/v1/WindowsCoreIdentity/uid/${uid}" -Method Get -Headers @{"Accept" = "application/json"} -ErrorAction Stop
      }
      catch {
          Invoke-RestMethod -Uri "${BASE_URI}/v1/WindowsCoreIdentity" -Method Post -UseBasicParsing -Body $body -Header @{"Accept" = "application/json"} -ContentType "application/json"
      }

    }
  }
}
    