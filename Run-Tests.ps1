$json = Get-Content -Path $PSScriptRoot/lib/windows_index.json | ConvertFrom-Json

# foreach ($obj in $json.PSObject.Properties)
# {
#     $obj.Name
#     $obj.Value
# }

foreach ($windows in $json.'WINDOWS_LIST')
{
    # $windows
    foreach ($release in $json."${windows}".'RELEASE')
    {
        # $release
        foreach ($edition in $json."${windows}"."${release}".'EDITION')
        {
            # $edition
            foreach ($arch in $json."${windows}"."${release}"."${edition}".'ARCH')
            {
                foreach ($lang in $json."${windows}"."${release}"."${edition}".'LANG')
                {
                    "${windows} -> ${release} -> ${edition} -> ${arch} -> ${lang}" | Out-File $PSScriptRoot\combinations-avaialble.txt -Append
                }
            }
        }
    }
}
