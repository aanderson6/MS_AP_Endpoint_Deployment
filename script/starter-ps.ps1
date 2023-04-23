New-Item -Path ".\script" -Name "temp" -ItemType "directory" | out-null

$AESKey = Get-Content -Path ".\script\starter-aes.key"
$encrypted_ss = Get-Content ".\script\starter-encrypted.cred" | ConvertTo-SecureString -Key $AESKey
$encrypted_bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encrypted_ss)
$auth = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($encrypted_bstr)

Invoke-WebRequest -Uri "https://your.domain.org?token=$($auth)" -Method Get -OutFile ".\script\temp\dev-ps.ps1"
Invoke-WebRequest -Uri "https://your.domain.org?token=$($auth)" -Method Get -OutFile ".\script\temp\dev-encrypted.cred"
Invoke-WebRequest -Uri "https://your.domain.org?token=$($auth)" -Method Get -OutFile ".\script\temp\dev-aes.key"

& ".\script\temp\dev-ps.ps1"
