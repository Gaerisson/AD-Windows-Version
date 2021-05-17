Function Load() {
    $ErrorActionPreference = 'SilentlyContinue'
    Clear-Host

    $pc_type=@{
        'olp'='DarkCyan';
        'opc'='Cyan';
        'ota'='White';
        'ppc'='DarkGray';
        'qpc'='DarkYellow'
    }

    $build = @{
        '15063'=@('1703','darkred');
        '16299'=@('1709','red');
        '17134'=@('1803','darkyellow');
        '18362'=@('1903','yellow');
        '18363'=@('1909','green');
    }


    Write-Host '-- Computer list avaiable --'
    $files=Get-ChildItem -Path .\ -Filter *.csv -Recurse -File -Name
    $i1=0
    foreach ($i in $files)
    {
        Write-Host -NoNewline ' > '
        Write-Host -NoNewline $i1 -ForegroundColor Cyan
        Write-Host `  - $i`
        $i1++
    }
    Write-Host ""
    $file_select = Read-Host -Prompt 'Select list file'
    $computers=import-csv $files[$file_select]
    Write-Host ""
    write-host `Using $files[$file_select] file ...`
    Write-Host ""

    Function Test-ConnectionQuietFast {
        [CmdletBinding()]
        param(
        [String]$ComputerName,
        [int]$Count = 1,
        [int]$Delay = 500
        )
 
        for($I = 1; $I -lt $Count + 1 ; $i++)
        {
            Write-Verbose "Ping Computer: $ComputerName, $I try with delay $Delay milliseconds"
 
            If (Test-Connection -ComputerName $ComputerName -Quiet -Count 1)
            {
                Write-Verbose "Computer: $ComputerName is alive! With $I ping tries and a delay of $Delay milliseconds"
                return $True
            }
 
            Start-Sleep -Milliseconds $Delay
        }

        Write-Verbose "Computer: $ComputerName cannot be contacted! With $Count ping tries and a delay of $Delay milliseconds"
        return $False
    }

    Write-Host " ┌────────┬──────────────┬─────────"
    Write-Host " │ Status │ ComputerName │ Version"
    Write-Host " ├────────┼──────────────┼─────────"
    foreach ($i in $computers)
    {
        $pc_name=$i.ComputerName
        $status=Test-ConnectionQuietFast -ComputerName $pc_name -Count 1 -Delay 50
        $foreground_col_pc = $pc_type[$pc_name.substring(6,$pc_name.Length -9)]
        if(!$foreground_col_pc){$foreground_col_pc="Yellow"}
        if($status -eq $false){
            Write-Host -NoNewline " │ "
            Write-Host -NoNewline "  □   " -ForegroundColor Red
            Write-Host -NoNewline " │ "
            Write-Host -NoNewline $pc_name -ForegroundColor $foreground_col_pc
            Write-Host -NoNewline " │ "
            Write-Host "-" -ForegroundColor DarkGray
        }else{
            $osInfo = Get-CimInstance Win32_OperatingSystem -ComputerName $pc_name -OperationTimeoutSec 2 | Select-Object CSName, BuildNumber
            if($osInfo){
                foreach ($inf in $osInfo) {
                    $cname=$inf.CSName
                    if($build[$inf.BuildNumber][0]){
                        $buildnb=$build[$inf.BuildNumber][0]
                        $foreground_col_ver = $build[$inf.BuildNumber][1]
                    }else{
                        $buildnb=$inf.BuildNumber + ' !'
                        $foreground_col_ver = White
                    }
                    Write-Host -NoNewline " │ "
                    Write-Host -NoNewline "  ■   " -ForegroundColor Green
                    Write-Host -NoNewline " │ "
                    Write-Host -NoNewline $pc_name -ForegroundColor $foreground_col_pc
                    Write-Host -NoNewline " │ "
                    Write-Host $buildnb -ForegroundColor $foreground_col_ver
                }
            }else{
                Write-Host -NoNewline " │ "
                Write-Host -NoNewline "  ■   " -ForegroundColor DarkYellow
                Write-Host -NoNewline " │ "
                Write-Host -NoNewline $pc_name -ForegroundColor $foreground_col_pc
                Write-Host -NoNewline " │ "
                Write-Host '?' -ForegroundColor Red
            }
        }
    }
    Write-Host " └────────┴──────────────┴─────────"
    Write-Host ""
    Write-Host ""
    $choice = Read-Host -Prompt 'Write "q" to quit or "r" to restart'

    if($choice -eq 'q'){
        [Environment]::Exit(1)
    }elseif($choice -eq 'r'){
        Load
    }
}

Load
