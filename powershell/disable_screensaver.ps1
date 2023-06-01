# Source : https://dmitrysotnikov.wordpress.com/2009/06/29/prevent-desktop-lock-or-screensaver-with-powershell/


param($minutes = 480) #//Duration. Until 480 mins (8h) below script will run

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  echo "tick $i"
  Start-Sleep -Seconds 60 #//every 60 secs do a key press

  $myshell.sendkeys("{SCROLLLOCK}")
  Start-Sleep -Milliseconds 100
  $myshell.sendkeys("{SCROLLLOCK}")
}