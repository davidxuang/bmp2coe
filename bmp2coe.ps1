param(
    [Parameter(Mandatory = $true, Position = 0)][ValidateSet('bgr24', 'rgb565le', 'rgb444le')][string]$PixelFormat
)

foreach ($file in (Get-ChildItem *.bmp)) {
    try {
        $stream = New-Object IO.FileStream $file.FullName, 'Open'
        $reader = New-Object IO.BinaryReader $stream

        $stream.Seek(0x0A, [IO.SeekOrigin]::Begin) | Out-Null
        $offset = $reader.ReadInt32()
        if ($offset -lt 0x36) { throw }

        $stream.Seek(0x12, [IO.SeekOrigin]::Begin) | Out-Null
        $width = $reader.ReadInt32()
        if ($width -le 0) { throw }

        $stream.Seek(0x16, [IO.SeekOrigin]::Begin) | Out-Null
        $height = $reader.ReadInt32()
        if ($height -le 0) { throw }
        
        if ($width % 2 -eq 1) { $widthPadding = 1 } else { $widthPadding = 0 }

        $stream.Seek($offset, [IO.SeekOrigin]::Begin) | Out-Null
        $coe = "MEMORY_INITIALIZATION_RADIX=16;`nMEMORY_INITIALIZATION_VECTOR="

        switch ($PixelFormat) {
            'bgr24' {
                for ($i = 0; $i -lt $height; $i++) {
                    $stream.Seek($offset + ($height - $i - 1) * ($width + $widthPadding) * 3, [IO.SeekOrigin]::Begin) | Out-Null
                    for ($j = 0; $j -lt $width; $j++) {
                        if (($i -eq $height - 1) -and ($j -eq $width - 1)) {
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ',')
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ',')
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ';')
                        } else {
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ',')
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ',')
                            $coe += ("`n" + ('{0:X2}' -f $reader.ReadByte()) + ',')
                        }
                    }
                }
            }
            'rgb565le' {
                for ($i = 0; $i -lt $height; $i++) {
                    $stream.Seek($offset + ($height - $i - 1) * ($width + $widthPadding) * 2, [IO.SeekOrigin]::Begin) | Out-Null
                    for ($j = 0; $j -lt $width; $j++) {
                        if (($i -eq $height - 1) -and ($j -eq $width - 1)) {
                            $coe += ("`n" + ('{0:X4}' -f $reader.ReadUInt16()) + ';')
                        } else {
                            $coe += ("`n" + ('{0:X4}' -f $reader.ReadUInt16()) + ',')
                        }
                    }
                }
            }
            'rgb444le' {
                for ($i = 0; $i -lt $height; $i++) {
                    $stream.Seek($offset + ($height - $i - 1) * ($width + $widthPadding) * 2, [IO.SeekOrigin]::Begin) | Out-Null
                    for ($j = 0; $j -lt $width; $j++) {
                        if (($i -eq $height - 1) -and ($j -eq $width - 1)) {
                            $coe += ("`n" + ('{0:X3}' -f $reader.ReadUInt16()) + ';')
                        } else {
                            $coe += ("`n" + ('{0:X3}' -f $reader.ReadUInt16()) + ',')
                        }
                    }
                }
            }
            default { throw }
        }

        Set-Content -Value $coe -Path ($file.BaseName + '.coe')
        Write-Output ('Conversion of ' + $file.Name + ' succeeded.')
    } catch {
        Write-Output ('Conversion of ' + $file.Name + ' failed.')
    } finally {
        if ($reader -ne $null) { $reader.Dispose() }
    }
}
