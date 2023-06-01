# handle Ctrl+c keys
[console]::TreatControlCAsInput = $true;

# boilerplate code
Add-Type -TypeDefinition @"
  using System;
  using System.Runtime.InteropServices;
  using System.Text;
  public class APIFuncs {
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int GetWindowText(IntPtr hwnd, StringBuilder lpString, int cch);
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern Int32 GetWindowTextLength(IntPtr hWnd);
  }
"@

function log {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$LogMessage
  )
  Write-Output ("{0} - {1}" -f (Get-Date), $LogMessage);
}

function addInHashTable {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [System.Collections.Hashtable]$ht,
    [Parameter(Mandatory=$true, Position=1)]
    [string]$keyName
  )
  if ($ht[$keyName] -eq "") {
    # no key in the hashmap, we add the key with a default 1s
    $ht[$keyName] = 1;
  }
  else {
    # add 1s to the existing key in hashmap
    $ht[$keyName] = $ht[$keyName] + 1;
  }
}


$startTime = $(get-date);
$hashTable = @{};

while(1) {
  if($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character)) {
    # Ctrl+C pressed : we exit the script
    $elapsedTime = $(get-date) - $startTime;
    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks);
    log "total time : $($totalTime)";
    
    # display the content of the hashtable in descending order
    $hashTable.GetEnumerator() | 
	  Sort-Object { $_.Value } -Descending | 
	  ForEach-Object { echo "$($_.Key) : $($_.Value)"; };
    break;
  }

  # get an handle of the current window
  $hWnd = [apifuncs]::GetForegroundWindow();
  
  if ($hWnd -eq 0) {
    # Sometimes, when switching windows, this variable can be set to 0.
    # We break the loop to get a proper value.
    continue;
  }
  
  $winProc = get-process | ? { $_.mainwindowhandle -eq $hWnd };
  # Get list of properties with "Get-Member" : get-process | ? { $_.mainwindowhandle -eq $hWnd } | Get-Member
  log "name : $($winProc.ProcessName)";
  
  # trick to get window title
  # https://stackoverflow.com/a/70010344
  $len = [apifuncs]::GetWindowTextLength($hWnd);
  $sb = New-Object text.stringbuilder -ArgumentList ($len + 1);
  $rtnlen = [apifuncs]::GetWindowText($hWnd,$sb,$sb.Capacity);
  log "title: $($sb.tostring())";
  
  # Not used, but i will maybe use this code one day.
  # Used to retrieve the PID of the window.
  #$myPid = [IntPtr]::Zero;
  #$retId = [apifuncs]::GetWindowThreadProcessId($hWnd, [ref] $myPid);
  #echo "id : $myPid / $retId";
  
  # check if the ProcessName is set (happen whis the file explorer and maybe other apps)
  if ($winProc.ProcessName -eq $null) {
    addInHashTable $hashTable "xxx";
  }
  else {
    addInHashTable $hashTable $winProc.ProcessName;
  }
  
  echo "----------------------------------------------";
  sleep 1;
}

