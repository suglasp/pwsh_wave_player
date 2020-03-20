
#
# Pieter De Ridder
# 20/03/2020
#
# demo : play a wave file in PWSH
# use standard method of playing wave file or streaming a wave file.
#

#Region Load assemblies needed
Add-Type -AssemblyName System.IO
#Add-Type -AssemblyName System.IO.MemoryStream
#Add-Type -AssemblyName System.Media

# [appdomain]::CurrentDomain.GetAssemblies()  # verify if the libs are loaded
#EndRegion

$sfxroot     = "$($PSScriptRoot)"
$sfxPowerOn  = "$($sfxroot)\poweron_generator.wav"
$sfxPowerOff = "$($sfxroot)\poweroff_generator.wav"

# create a global sound player
[System.Media.SoundPlayer]$global:WavePlayer = New-Object System.Media.SoundPlayer


#
# Function : Play-WaveFile
# Play a RIFF file (from disk)
#
Function Play-WaveFile {
    Param(
        [string]$WaveFilename
    )

    If (Test-Path $WaveFilename) {
        Write-Host "Playing $($WaveFilename) as a file..." 
        $global:WavePlayer.SoundLocation = $WaveFilename
	    $global:WavePlayer.PlaySync()
    } Else {
        Write-Warning "File $($WaveFilename) not found?!"    
    }
}


#
# Function : Play-WaveStream
# Play a RIFF stream of bytes
#
Function Play-WaveStream {
    Param(
        [System.Byte[]]$WaveSteam
    )

    If ($WaveSteam) {
        If ($WaveSteam.Length -gt 0) {
            Write-Host "Playing stream..." 
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


# -- play a wave file
# provide filename
Play-WaveFile -WaveFilename $sfxPowerOn

# -- play a wave stream
# load file in byte array and stream
[System.Byte[]]$bytes = [System.IO.File]::ReadAllBytes($sfxPowerOff)
Play-WaveStream -WaveSteam $bytes
$bytes = $null
