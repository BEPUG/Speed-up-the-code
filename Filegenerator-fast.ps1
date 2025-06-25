function New-PlcLog {
    $bigFileName = "plc_log.txt"
    $plcNames = [string[]]@('PLC_A','PLC_B','PLC_C','PLC_D')
    $errorTypes = [string[]]@(
        'Sandextrator overload',
        'Conveyor misalignment',
        'Valve stuck',
        'Temperature warning'
    )
    $statusCodes = [string[]]@('OK','WARN','ERR')

    $rand = [System.Random]::new()
    $baseTime = [DateTime]::UtcNow

    # Preallocate a fast .NET list (much faster than PowerShell arrays)
    $lines = New-Object 'System.Collections.Generic.List[string]' 50000

    for ($i = 0; $i -lt 50000; $i++) {
        $ts = $baseTime.AddSeconds(-$i)
        $timestamp = "{0:yyyy-MM-dd HH:mm:ss}" -f $ts
        $plc = $plcNames[$rand.Next(4)]
        $operator = $rand.Next(101, 121)
        $batch = $rand.Next(1000, 1101)
        $status = $statusCodes[$rand.Next(0, 3)]
        $machineTemp = [math]::Round($rand.Next(60, 110) + $rand.Next(), 2)
        $load = $rand.Next(0, 101)

        if ($rand.Next(1, 8) -eq 4) {
            $errorType = $errorTypes[$rand.Next(0, 4)]
            if ($errorType -eq 'Sandextrator overload') {
                $value = $rand.Next(1, 11)
                $lines.Add("ERROR; $timestamp; $plc; $errorType; $value; $status; $operator; $batch; $machineTemp; $load")
            } else {
                $lines.Add("ERROR; $timestamp; $plc; $errorType; ; $status; $operator; $batch; $machineTemp; $load")
            }
        } else {
            $lines.Add("INFO; $timestamp; $plc; System running normally; ; $status; $operator; $batch; $machineTemp; $load")
        }
    }

    # Fastest way to write all lines at once
    [System.IO.File]::WriteAllLines($bigFileName, $lines)
    Write-Output "PLC log file generated."
}

# 2) One-time warm-up (not measured)
if (-not $global:jitted) {
    # Call everything you’ll use once so it gets JIT-compiled
    New-PlcLog
    [void][System.Random]::new().Next(0,1)
    [void][DateTime]::UtcNow
    $global:jitted = $true
}

# 3) Now measure only the real work
Measure-Command { New-PlcLog } 
