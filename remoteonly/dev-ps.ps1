####################
# MAIN PROCESS
####################
Function main {
    $devicetype = Prompt-ForDeviceType
    AddToAutoPilot $devicetype
}

####################
# MAIN FUNCTIONS
####################

Function Prompt-ForDeviceType {
    $title = "Select Device Type:"
    #Using passthru devicetype as grouptag
    $hmenu = @{"DeviceType1"="DeviceType1";"DeviceType2"="DeviceType2"}
    $devicetype = Show-NavigationableMenu $title $hmenu
    return $devicetype
}

#function borrowed from : https://www.powershellgallery.com/packages/PowerShellFrame/0.0.0.20/Content/Public%5CShow-NavigationableMenu.ps1
# thanks to that ps contributor
function Show-NavigationableMenu() {
    param (
        [System.String]$sMenuTitle,
        [System.Collections.Hashtable]$hMenuEntries
    )
    # Orginal Konsolenfarben zwischenspeichern
    [System.Int16]$iSavedBackgroundColor=[System.Console]::BackgroundColor
    [System.Int16]$iSavedForegroundColor=[System.Console]::ForegroundColor
    # Menu Colors
    # inverse fore- and backgroundcolor
    [System.Int16]$iMenuForeGroundColor=$iSavedForegroundColor
    [System.Int16]$iMenuBackGroundColor=$iSavedBackgroundColor
    [System.Int16]$iMenuBackGroundColorSelectedLine=$iMenuForeGroundColor
    [System.Int16]$iMenuForeGroundColorSelectedLine=$iMenuBackGroundColor
    # Alternative, colors
    #[System.Int16]$iMenuBackGroundColor=0
    #[System.Int16]$iMenuForeGroundColor=7
    #[System.Int16]$iMenuBackGroundColorSelectedLine=10
    # Init
    [System.Int16]$iMenuStartLineAbsolute=0
    [System.Int16]$iMenuLoopCount=0
    [System.Int16]$iMenuSelectLine=1
    [System.Int16]$iMenuEntries=$hMenuEntries.Count
    [Hashtable]$hMenu=@{};
    [Hashtable]$hMenuHotKeyList=@{};
    [Hashtable]$hMenuHotKeyListReverse=@{};
    [System.Int16]$iMenuHotKeyChar=0
    [System.String]$sValidChars=""
    [System.Console]::WriteLine(" "+$sMenuTitle)
    # Für die eindeutige Zuordnung Nummer -> Key
    $iMenuLoopCount=1
    # Start Hotkeys mit "1"!
    $iMenuHotKeyChar=49
    foreach ($sKey in $hMenuEntries.Keys){
        $hMenu.Add([System.Int16]$iMenuLoopCount,[System.String]$sKey)
        # Hotkey zuordnung zum Menueintrag
        $hMenuHotKeyList.Add([System.Int16]$iMenuLoopCount,[System.Convert]::ToChar($iMenuHotKeyChar))
        $hMenuHotKeyListReverse.Add([System.Convert]::ToChar($iMenuHotKeyChar),[System.Int16]$iMenuLoopCount)
        $sValidChars+=[System.Convert]::ToChar($iMenuHotKeyChar)
        $iMenuLoopCount++
        $iMenuHotKeyChar++
        # Weiter mit Kleinbuchstaben
        if($iMenuHotKeyChar -eq 58){$iMenuHotKeyChar=97}
        # Weiter mit Großbuchstaben
        elseif($iMenuHotKeyChar -eq 123){$iMenuHotKeyChar=65}
        # Jetzt aber ende
        elseif($iMenuHotKeyChar -eq 91){
            Write-Error " Menu too big!"
            exit(99)
        }
    }
    # Remember Menu start
    [System.Int16]$iBufferFullOffset=0
    $iMenuStartLineAbsolute=[System.Console]::CursorTop
    do{
        ####### Draw Menu #######
        [System.Console]::CursorTop=($iMenuStartLineAbsolute-$iBufferFullOffset)
        for ($iMenuLoopCount=1;$iMenuLoopCount -le $iMenuEntries;$iMenuLoopCount++){
            [System.Console]::Write("`r")
            [System.String]$sPreMenuline=""
            $sPreMenuline=" "+$hMenuHotKeyList[[System.Int16]$iMenuLoopCount]
            $sPreMenuline+=": "
            if ($iMenuLoopCount -eq $iMenuSelectLine){
                [System.Console]::BackgroundColor=$iMenuBackGroundColorSelectedLine
                [System.Console]::ForegroundColor=$iMenuForeGroundColorSelectedLine
            }
            if ($hMenuEntries.Item([System.String]$hMenu.Item($iMenuLoopCount)).Length -gt 0){
                [System.Console]::Write($sPreMenuline+$hMenuEntries.Item([System.String]$hMenu.Item($iMenuLoopCount)))
            }
            else{
                [System.Console]::Write($sPreMenuline+$hMenu.Item($iMenuLoopCount))
            }
            [System.Console]::BackgroundColor=$iMenuBackGroundColor
            [System.Console]::ForegroundColor=$iMenuForeGroundColor
            [System.Console]::WriteLine("")
        }
        [System.Console]::BackgroundColor=$iMenuBackGroundColor
        [System.Console]::ForegroundColor=$iMenuForeGroundColor
        #[System.Console]::Write(" Your choice: " )
        if (($iMenuStartLineAbsolute+$iMenuLoopCount) -gt [System.Console]::BufferHeight){
            $iBufferFullOffset=($iMenuStartLineAbsolute+$iMenuLoopCount)-[System.Console]::BufferHeight
        }
        ####### End Menu #######
        ####### Read Kex from Console
        $oInputChar=[System.Console]::ReadKey($true)
        # Down Arrow?
        if ([System.Int16]$oInputChar.Key -eq [System.ConsoleKey]::DownArrow){
            if ($iMenuSelectLine -lt $iMenuEntries){
                $iMenuSelectLine++
            }
        }
        # Up Arrow
        elseif([System.Int16]$oInputChar.Key -eq [System.ConsoleKey]::UpArrow){
            if ($iMenuSelectLine -gt 1){
                $iMenuSelectLine--
            }
        }
        elseif([System.Char]::IsLetterOrDigit($oInputChar.KeyChar)){
            #[System.Console]::Write($oInputChar.KeyChar.ToString())
        }
        [System.Console]::BackgroundColor=$iMenuBackGroundColor
        [System.Console]::ForegroundColor=$iMenuForeGroundColor
    } while(([System.Int16]$oInputChar.Key -ne [System.ConsoleKey]::Enter)) #-and ($sValidChars.IndexOf($oInputChar.KeyChar) -eq -1))

    # reset colors
    [System.Console]::ForegroundColor=$iSavedForegroundColor
    [System.Console]::BackgroundColor=$iSavedBackgroundColor
    if($oInputChar.Key -eq [System.ConsoleKey]::Enter){
        #[System.Console]::Writeline($hMenuHotKeyList[$iMenuSelectLine])
        return([System.String]$hMenu.Item($iMenuSelectLine))
    }
    #else{
    #    [System.Console]::Writeline("")
    #    return($hMenu[$hMenuHotKeyListReverse[$oInputChar.KeyChar]])
    #}
}


#This function is a highly modified variation of this script for better use:
#https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo/3.5/Content/Get-WindowsAutoPilotInfo.ps1

Function AddToAutoPilot($devicetype) {

    ####################
    # IMPORT MODULES
    ####################

    Write-Host "Importing modules..."

    if (!(Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        install-packageprovider -name nuget -minimumversion 2.8.5.201 -force | out-null
    }

    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted | out-null

    if (!(Get-Module -ListAvailable -Name AzureAD)) {
        Install-Module AzureAD | out-null
    }
    Import-Module AzureAD

    if (!(Get-Module -ListAvailable -Name WindowsAutopilotIntune)) {
        Install-Module WindowsAutopilotIntune | out-null
    }
    Import-Module WindowsAutopilotIntune

    ####################
    # AZURE CONNECTIONS
    ####################

    Write-Host "Connecting to Azure..."

    $TenantId = ""
    $AppId = ""
    $AESKey = Get-Content -Path ".\script\temp\dev-aes.key" 
    $encrypted_ss = Get-Content ".\script\temp\dev-encrypted.cred" | ConvertTo-SecureString -Key $AESKey
    $encrypted_bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encrypted_ss)
    $encrypted_decrypted = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($encrypted_bstr)

    # Create MGGraph Connect body
    $body =  @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        Client_Id     = $AppId
        Client_Secret = $encrypted_decrypted
    }

    #Get Token and Connect
    $connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Method POST -Body $body
    $token = $connection.access_token

    Connect-MSGraphApp -Tenant $TenantId -AppId $AppId -AppSecret $encrypted_decrypted
    #Connect-MgGraph -AccessToken $token | out-null

    #######################
    # GATHER HARDWARE INFO
    #######################

    Write-Host "Gathering hardware information..."

    $session = New-CimSession
    $serialnumber = (Get-CimInstance -CimSession $session -Class Win32_BIOS).SerialNumber
    $devDetail = (Get-CimInstance -CimSession $session -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")

    if ($devDetail) {
        $hardwarehash = $devDetail.DeviceHardwareData
    } else {
        Write-Error -Message "Unable to retrieve device hardware data (hash) from computer $comp" -Category DeviceError
        exit
    }
    Remove-CimSession $session

    #######################
    # GET GROUPNAME AND TAG
    #######################

    #groupname not in use due to known issues with Graph API using app to join devices to groups
    switch ($devicetype) {
        "DeviceType1" {
            $groupname = "XXX"
            $grouptag = "DeviceType1Tag"
        } "DeviceType2" {
            $groupname = "XXX"
            $grouptag = "DeviceType2Tag"
        } 
    }

    #######################
    # IMPORT AND WAIT
    #######################

    Write-Host "Sending import request..."

    #Begin import device
    $importedDevice = Add-AutopilotImportedDevice -serialNumber $serialnumber -hardwareIdentifier $hardwarehash -groupTag $grouptag -assignedUser ""

    #Wait for device to be imported
    while (1) {
        $device = Get-AutopilotImportedDevice -id $importedDevice.id
        if ($device.state.deviceImportStatus -eq "complete") {
            break
        } elseif ($device.state.deviceImportStatus -eq "error") {
            Write-Host "IMPORT ERROR! $($device.serialNumber): $($device.state.deviceImportStatus) $($device.state.deviceErrorCode) $($device.state.deviceErrorName)"
            exit
        }
        Write-Host "Waiting for device to be imported to autopilot..."
        Start-Sleep 30
    }
    Write-Host "----- Device Import Complete -----"

    # Wait for device to move out of imported queue into autopilot
    while (1) {
        $autopilotDevice = Get-AutopilotDevice -id $device.state.deviceRegistrationId
        if ($autopilotDevice) {
            break
        }
        Write-Host "Waiting for device to be synced to autopilot..."
        Start-Sleep 30
    }

    # Wait for device profile to be assigned
    while (1) {
        $device = Get-AutopilotDevice -id $autopilotDevice.id -Expand
        if ($device.deploymentProfileAssignmentStatus.StartsWith("assigned")) {
            break
        }
        
        Write-Host "Waiting for device profile to be assigned..."
        Start-Sleep 30
    }
    Write-Host "----- Device Assignment Complete -----"

    #######################
    # ADD TO GROUP
    #######################

    #$az_group = Get-AzureADGroup -Filter "DisplayName eq '$($groupname)'"
    #$aad_dev = Get-AzureADDevice -ObjectId "deviceid_$($autopilotDevice.AzureActiveDirectoryDeviceId)"
    #Add-AzureADGroupMember -ObjectId $az_group.ObjectId -RefObjectId $aad_dev.ObjectId
    #Write-Host "Added device to group. Restarting."

    #$az_group = Get-MgGroup -Filter "DisplayName eq '$($groupname)'"
    #$aad_dev = Get-MgDevice -Filter "deviceId eq '$($autopilotDevice.AzureActiveDirectoryDeviceId)'"
    #New-MgGroupMember -GroupId $az_group.id -DirectoryObjectId $aad_dev.Id

    Remove-Item -Path ".\script\temp" -Recurse -Force

    Write-Host "Restarting..."
    Restart-Computer -Force
}

#######################
# RUN MAIN
#######################

main