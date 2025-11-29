@ECHO OFF
sfc /SCANNOW
DISM.exe /Online /Cleanup-Image /RestoreHealth
