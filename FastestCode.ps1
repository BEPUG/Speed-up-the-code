Measure-Command {
    # Set file name
    $bigFileName = "plc_log.txt"
    # Create new .NET class written in C# . C# Has a verry similar way of writing as PowerShell
    Add-Type -TypeDefinition @'
using System;
using System.Text;

public class FastFast
{
    public static string Generate(DateTime start, int count)
    {
        var sb = new StringBuilder(count * 100);
        long ticksPerSecond = TimeSpan.TicksPerSecond;
        long startTicks = start.Ticks;
        var rng = new Random();
        string[] plcNames = { "PLC_A", "PLC_B", "PLC_C", "PLC_D" };
        string[] statusCodes = { "OK", "WARN", "ERR" };
        string[] errorTypes = { "Sandextrator overload", "Conveyor misalignment", "Valve stuck", "Temperature warning" };

        for (int i = 0; i < count; i++)
        {
            var dt = new DateTime(startTicks - i * ticksPerSecond);
            string plc = plcNames[rng.Next(plcNames.Length)];
            string status = statusCodes[rng.Next(statusCodes.Length)];
            int op = rng.Next(101, 121);
            int batch = rng.Next(1000, 1101);
            int load = rng.Next(0, 101);
            uint machineTemp = (uint)(rng.Next(60, 110) + rng.Next(0, 2147483647));
            if (rng.Next(1, 8) == 4)
            {
                string errorType = errorTypes[rng.Next(errorTypes.Length)];
                sb.Append("ERROR; ");
                sb.AppendFormat("{0:yyyy-MM-dd HH:mm:ss}; ", dt);
                if (errorType == "Sandextrator overload")
                {
                    int value = rng.Next(1, 11);
                    sb.Append($"{plc}; {errorType}; {value}; {status}; {op}; {batch}; {machineTemp}; {load}\n");
                }
                else
                {
                    sb.Append($"{plc}; {errorType}; ; {status}; {op}; {batch}; {machineTemp}; {load}\n");
                }
            }
            else
            {
                sb.Append("INFO; ");
                sb.AppendFormat("{0:yyyy-MM-dd HH:mm:ss}; ", dt);
                sb.Append($"{plc}; System running normally; ; {status}; {op}; {batch}; {machineTemp}; {load}\n");
            }
        }
        return sb.ToString();
    }
}
'@
    # Get your DateTime
    $start = [DateTime]::Now
    # Generate the Log
    $log = ([FastFast]::Generate($start, 50000)).trim("`n").split("`n")
    # Output the file with the .Net method 
    [System.IO.File]::WriteAllLines($bigFileName, $log)
    Write-Output "PLC log file generated."
}