# Script used to change the lock screen wallpaper on windows 10
# with random image from a given directory.
# 
# Schedule the task with the Windows Task Scheduler :
# http://www.metalogix.com/help/Content%20Matrix%20Console/SharePoint%20Edition/002_HowTo/004_SharePointActions/012_SchedulingPowerShell.htm
#
# function 'Set-LockscreenWallpaper' written by :
# https://github.com/Sauler/PowershellUtils
#
# Dependency : PoshWinRT.dll (see the github repo)


function Set-LockscreenWallpaper($path) {
    Add-Type -Path PoshWinRT.dll
	[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime]
	$asyncOp = [Windows.Storage.StorageFile]::GetFileFromPathAsync($path)
	$typeName = 'PoshWinRT.AsyncOperationWrapper[Windows.Storage.StorageFile]'
	$wrapper = new-object $typeName -Arg $asyncOp
	$file = $wrapper.AwaitResult()
	$null = [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime]
	[Windows.System.UserProfile.LockScreen]::SetImageFileAsync($file)
}


# directory with all wallpaper
$dirPath = "C:\path\to\directory"

# double the '\' char with some weird commandlet
$dirPathDouble = $dirPath -replace "\\","\\"

# pass the double slashed directory to the Get-ChildItem commandlet and retrieve a random file name
$file = Get-ChildItem "$dirPathDouble" | Get-Random

# call the lock screen function with the random selected image
Set-LockscreenWallpaper("$dirPath\$file") | out-null

# sleep because why not -_-
Start-Sleep -m 300


#-----------------------------------------------------------------------------------------------------
# leave some stuff here...
#if ($args.Length -eq 1) {Set-LockscreenWallpaper($args[0])}