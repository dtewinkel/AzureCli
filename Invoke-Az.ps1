$process = [System.Diagnostics.Process]::New()
$process.StartInfo.FileName = (Get-Command az).Path
$process.StartInfo.Arguments = 'account list'
$process.StartInfo.CreateNoWindow = $true
$process.StartInfo.RedirectStandardInput = $true
$process.StartInfo.RedirectStandardOutput = $true

if($process.Start())
{
	$process.WaitForExit()
}

$process.ExitCode
$process.ExitTime - $process.StartTime

Write-Host $process.StandardOutput.ReadToEnd()

