$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packageArgs = @{
  packageName   = 'metire'
  url           = 'https://github.com/arTTiK9408/metire/releases/download/v1.0/metire-windows-x86_64.exe'
  checksum      = ''
  checksumType  = 'sha256'
  fileFullPath  = Join-Path $toolsDir 'metire.exe'
}

Get-ChocolateyWebFile @packageArgs
