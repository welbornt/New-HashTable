# New-HashTable.ps1 : Build a hash table for the files in a given directory
# Version : 1.0
# Copyright 2022 Timothy Welborn
# License: New BSD License

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $Path,
    [Parameter(Mandatory=$true)]
    [String]
    $Destination,
    [Parameter(Mandatory=$false)]
    [Switch]
    $Recurse = $false,
    [Parameter(Mandatory=$false)]
    [Switch]
    $Force = $false,
    [Parameter(Mandatory=$False)]
    [Switch]
    $Skip = $false,
    [ValidateScript({@('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5').Contains($_)})]
    [Parameter(Mandatory=$false)]
    [String]
    $Algorithm = 'SHA256'
)

function WriteHash($filePath){
    try {
        $fileHash = Get-FileHash -Path $filePath -Algorithm $Algorithm
        Add-Content -Path $Destination -Value "$filePath, $($fileHash.Hash)"
    }
    catch {
        if ($Skip -eq $false){
            Write-Error "Error hashing $filePath Hashing stopped. Check file permissions and try again or use the -Skip flag to silently skip file access errors."
            Exit 3
        }
    }
}

# entry point
if (!(Test-Path -Path $Path -PathType Container)){
    Write-Error "The path $Path is invalid."
    Exit 1
}
elseif ((Test-Path -Path $Destination -PathType Leaf) -and ($false -eq $Force)){
    Write-Error "The file $Destination already exists. Use the -Force flag to overwrite this file."
    Exit 2
}
else {
    # init the csv file
    Set-Content -Path $Destination -Value "Path, HashValue,"
    if ($Recurse){
        foreach ($file in Get-ChildItem $Path -File -Recurse){
            WriteHash($file.FullName)
        }
    }
    else {
        foreach ($file in Get-ChildItem $Path -File){
            WriteHash($file.FullName)
        }
    }
}
