
#
# Pieter De Ridder
# created : 20/03/2020
# updated : 27/03/2021
#
# demo : play a wave file in PWSH
# We have 3 methods:
# - use standard method of playing wave file (sync)
# - use a method to stream a wave file in memory
# - use a method to play a wave file (sync) from a UNC path
#


#Region Load assemblies needed
Add-Type -AssemblyName System.IO
#Add-Type -AssemblyName System.IO.MemoryStream
#Add-Type -AssemblyName System.Media

# [appdomain]::CurrentDomain.GetAssemblies()  # verify if the libs are loaded
#EndRegion

# sfx paths
[string]$sfxroot       = "$($PSScriptRoot)"
[string]$sfxPowerOn    = "$($sfxroot)\poweron_generator.wav"
[string]$sfxPowerOff   = "$($sfxroot)\poweroff_generator.wav"
[string]$sfxPowerOnUNC = "\\someserver.domain.ext\someshare\poweron_generator.wav"



# create a global sound player Object
# (see it like a sound engine)
[System.Media.SoundPlayer]$global:WavePlayer = New-Object System.Media.SoundPlayer


#
# Function : Play-WaveFile
# Play a RIFF file (from disk) synchronious
#
Function Play-WaveFile {
    Param(
        [string]$WaveFilename
    )

    If (Test-Path -Path $WaveFilename) {
        Write-Host "Playing $($WaveFilename) as a file..." 
        $global:WavePlayer.SoundLocation = $WaveFilename
	    $global:WavePlayer.PlaySync()
    } Else {
        Write-Warning "File $($WaveFilename) not found?!"    
    }
}


#
# Function : Play-WaveStream
# Play a RIFF stream of bytes in memory
#
Function Play-WaveStream {
    Param(
        [System.Byte[]]$WaveSteam
    )

    If ($WaveSteam) {
        If ($WaveSteam.Length -gt 0) {
            Write-Host "Playing as a stream..."
            [System.IO.MemoryStream]$stream = New-Object System.IO.MemoryStream
            $stream.Write($WaveSteam, 0, $WaveSteam.Length)
            [void]$stream.Seek(0, [System.IO.SeekOrigin]::Begin)
            $global:WavePlayer.Stream = $stream
            $global:WavePlayer.PlaySync()
            $stream.Close()
            $stream.Dispose()
        } Else {
            Write-Warning "Stream empty!"   
        }
    } Else {
        Write-Warning "Steam is null!"
    }
}


#
# Function : Play-WaveNetwork
# Play a RIFF file (from disk) synchronious from a network UNC path
#
Function Play-WaveNetwork
{
    param(
        [string]$WaveUNCFilename,
        [switch]$KeepCached
    )
        
    # 'cache' the file to a local path
    # we can only play from a local path, not from a UNC path
    [string]$sfxRemoteFile = $WaveUNCFilename
    [string]$sfxLocalFile = "$($env:TEMP)\$(Split-Path -Path $WaveUNCFilename -Leaf)" 
    
    If (Test-Path -Path $WaveUNCFilename) {
        Write-Host "Playing as a file from UNC path..."
        Copy-Item -Path $sfxRemoteFile -Destination $sfxLocalFile -Force -ErrorAction SilentlyContinue
    } Else {
        Write-Warning "File $($WaveUNCFilename) not found?!"    
    }

    # play file if present from local location
    If (Test-Path -Path $sfxLocalFile) {  
        $global:WavePlayer.SoundLocation = $sfxLocalFile
	    $global:WavePlayer.PlaySync()
    }
    
    # cleanup, if requested
    If (-not ($KeepCached)) {
        If (Test-Path -Path $sfxLocalFile) {
            Remove-Item -Path $sfxLocalFile -Force -ErrorAction SilentlyContinue
        }
    }
}




# -- play a wave file (standard, synchronious)
# provide filename
Play-WaveFile -WaveFilename $sfxPowerOn

# -- play a wave stream
# load file in byte array and stream
[System.Byte[]]$bytes = [System.IO.File]::ReadAllBytes($sfxPowerOff)
Play-WaveStream -WaveSteam $bytes
$bytes = $null


# -- play a wave file from network UNC path
# provide filename, and optionally -KeepCached
Play-WaveNetwork -WaveUNCFilename $sfxPowerOnUNC
#Play-WaveNetwork -WaveUNCFilename $sfxPowerOnUNC -KeepCached