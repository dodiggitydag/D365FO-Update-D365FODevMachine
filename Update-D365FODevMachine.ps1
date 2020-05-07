#Install-Module d365fo.tools  # Must be installed
#Update-Module d365fo.tools
Import-Module d365fo.tools

Stop-D365Environment

# Get latest
$tf_exe_fullpath = "$env:ProgramFiles (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe"
$tf_exe = [System.IO.Path]::GetFileName($tf_exe_fullpath)
$workDir = [System.IO.Path]::GetDirectoryName($tf_exe_fullpath)
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "$workDir\$tf_exe"
$pinfo.WorkingDirectory = $workDir
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$pinfo.Arguments = "get ""$/Project/DEV/Main/Metadata"""  # Change this to the path of your branch

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$p.ExitCode # Should be zero, if not zero look at StandardError
$p.StandardOutput.ReadToEnd()
$p.StandardError.ReadToEnd()

###############################################################
# Visually check there are no errors before continuing
###############################################################

Get-D365Model -CustomizableOnly -ExcludeMicrosoftModels -ExcludeBinaryModels | Invoke-D365ModuleCompile | Get-D365CompilerResult -OutputAsObjects

###############################################################
# Visually check there are no errors before continuing
###############################################################
Invoke-D365DBSync

Start-D365Environment -OnlyStartTypeAutomatic  # Do not start Mgmt Reporter for development boxes
