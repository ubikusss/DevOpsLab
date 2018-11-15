#append the environment path to make sure that the path to the executable is there
#$env:Path = $env:Path + ";C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\dotnet"

#in CMD you can do: set PATH=%PATH%;C:\Windows\system32\config\systemprofile\AppData\Local\Microsoft\dotnet

#in the case that the any dotnet app is running it will be stopped for idempotency
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue

#clean folder
Remove-Item C:\WebApp\s\ -Force -Recurse -ErrorAction SilentlyContinue

#define function unzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

#Unzip the files and log the output
Unzip "C:\WebApp\s.zip" "C:\WebApp\s" > C:\WebApp\unzip.txt
#cd C:\WebApp\s\

#declare variable to expose port (this was for the old CLI version)
#$env:ASPNETCORE_URLS="https://*:5000"

#start application
Start-Process "C:\WebApp\dotnet.bat" -WindowStyle Hidden

