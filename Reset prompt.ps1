Remove-Item -Path $env:LOCALAPPDATA'\Microsoft\Windows Terminal\Fragments\custom_prompt' -Recurse
New-Item -Path $PROFILE -Type File -Force
