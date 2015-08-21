Import-Module webadministration
Set-ExecutionPolicy RemoteSigned
#############################################################################
#
# Creates all  Virtual directories for each web service with the new version
# In case this is a new Machine, creates the WebServices site.
# If needed, change the main path vdPath and directoryPath
#
#############################################################################

$sites = Get-Childitem 'IIS:\Sites'
#Products, define accordion to the application pool V2 or V4
#$ProductV2 = 
$ProductV4 = "API","Catalog","Notification","Social","Domains","Users","Billing","CAS","Pricing"

$Verstion = Read-Host 'Enter Version, for example: V3_2'
$Verstion_old = Read-Host 'Enter Previous Version, for example: V3_2'
$CopyFile = Read-Host 'Enter Y if you wish to copy config from previous version'
$MainPath = Read-Host 'Enter full path, for example: D:\spaces\webservices\Versions'


$vdPath = $MainPath 
$AppPollV2 = 'webservices V2.0'
$AppPollV4 = 'webservices V4.0'



$iisAppName = "webservices"
$directoryPath = $MainPath +"wwwroot\"
$iisAppPoolName = $AppPollV2
$iisAppPoolDotNetVersion = "v2.0"
$iisPort = "8030"

#create the app pool
if (!(Test-Path IIS:\AppPools\$AppPollV2 -pathType container))
{

    $appPool = New-Item IIS:\AppPools\$AppPollV2
    $appPool.managedRuntimeVersion = "v2.0"
    $appPool | Set-Item
    Write-Output "in" $AppPollV2
}

if (!(Test-Path IIS:\AppPools\$AppPollV4 -pathType container))
{

    $appPool = New-Item IIS:\AppPools\$AppPollV4
    $appPool.managedRuntimeVersion = "v4.0"
    $appPool | Set-Item
    Write-Output "in" $AppPollV4
}
 

#create folder
if (!( Test-Path $vdPath ))
{
    new-item $vdPath -itemtype directory
}
if (!( Test-Path $directoryPath ))
{
    new-item $directoryPath -itemtype directory
}

 #create site
 if (!(Test-Path IIS:\Sites\$iisAppName -pathType container))
 {
            #$iisAppName = "webservices"
            #$directoryPath = "C:\tvinci\web\webservices.tvinci.yes"
            #$iisAppPoolName = "webservices V2.0"
            #$iisAppPoolDotNetVersion = "v2.0"
            #$iisPort = "8030"
     New-WebSite -Name $iisAppName -Port $iisPort  -HostHeader $iisAppName -PhysicalPath $directoryPath -ApplicationPool $iisAppPoolName -Force

 }

         #New-WebBinding -name $iisAppName -port 80 -Protocol http -HostHeader $DNS -IPAddress "*"

 
foreach ($element in $ProductV2) {
    $path = $vdPath +'\' +$Verstion + '\'+ $element + '\'
	$sitename = 'IIS:\Sites\webservices\'+ $element + '_' + $Verstion
    #New-Item $path -type VirtualDirectory -physicalPath $vdPath
	New-Item $sitename -physicalPath $path -type Application -ApplicationPool $AppPollV2
    #Write-Output $path
    if ($CopyFile = 'Y')
        {
	        Copy-Item ($MainPath +'\' +$Verstion_old + '\'+ $element + '\web.config') ($MainPath +'\' +$Verstion + '\'+ $element + '\web.config')
	    }
    }
	
	
foreach ($element in $ProductV4) {
    $path = $vdPath +'\' +$Verstion + '\'+ $element + '\'
	$sitename = 'IIS:\Sites\webservices\'+ $element + '_' + $Verstion
    #New-Item $path -type VirtualDirectory -physicalPath $vdPath
	New-Item $sitename -physicalPath $path -type Application -ApplicationPool $AppPollV4
    #Write-Output $path
    if ($CopyFile = 'Y')
        {
	        Copy-Item ($MainPath +'\' +$Verstion_old + '\'+ $element + '\web.config') ($MainPath +'\' +$Verstion + '\'+ $element + '\web.config')
            (Get-Content $MainPath +'\' +$Verstion + '\'+ $element + '\web.config') | 
             Foreach-Object {$_ -replace $Verstion_old,$Verstion_old}  | 
             Out-File $MainPath +'\' +$Verstion + '\'+ $element + '\web.config'
        }
	}

		
