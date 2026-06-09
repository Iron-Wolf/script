# --- DOC ---

# Tooling
# ollama release  : https://github.com/ollama/ollama/releases
# search model    : https://ollama.com/library/tinyllama
# direct download : https://ollama-direct-downloader.vercel.app/

# get proxy info with : Get-ItemProperty -Path "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
# download "pac" file :  http://srvconfigie.encara.local.ads/pack/proxyNG.pac
$proxyUrl = "http://internetNG.encara.local.ads:8080"

# Run with        : .\ollama.exe run tinyllama:latest


# --- CONFIG ---
#$env:HTTP_PROXY  = $proxyUrl
#$env:HTTPS_PROXY = $proxyUrl
#Get-ChildItem env:HTTP_PROXY


# --- .NET PROXY ---
[System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($proxyUrl)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials


# --- HELPERS ---
function Download-File {
    param (
        [string]$Url,
        [string]$pathWithFileName
    )

    $dirPath = Split-Path $pathWithFileName
    New-Item -ItemType Directory -Path $dirPath -Force | Out-Null

    Invoke-WebRequest `
        -Uri $Url `
        -Proxy $proxyUrl `
        -ProxyUseDefaultCredentials `
        -OutFile $pathWithFileName
}


# --- MAIN ---
try {
    $base = "https://registry.ollama.ai/v2/library/tinyllama"
    
    # manifest
    Write-Host "start dl model ..."
    Download-File `
        "$base/manifests/latest" `
        "$env:USERPROFILE\.ollama\models\manifests\registry.ollama.ai\library\tinyllama\latest"

    # blobs
    Write-Host "start dl blobs ..."
    $blobs = @(
        "sha256-6331358be52a6ebc2fd0755a51ad1175734fd17a628ab5ea6897109396245362",
        "sha256-2af3b81862c6be03c769683af18efdadb2c33f60ff32ab6f83e42c043d6c7816",
        "sha256-af0ddbdaaa26f30d54d727f9dd944b76bdb926fdaf9a58f63f78c532f57c191f",
        "sha256-c8472cd9daed5e7c20aa53689e441e10620a002aacd58686aeac2cb188addb5c",
        "sha256-fa956ab37b8c21152f975a7fcdd095c4fee8754674b21d9b44d710435697a00d"
    )
    foreach ($blob in $blobs) {
        Download-File `
            "$base/blobs/$blob" `
            "$env:USERPROFILE\.ollama\models\blobs\$blob"
    }
}
finally {
    Write-Host "end !"
}

