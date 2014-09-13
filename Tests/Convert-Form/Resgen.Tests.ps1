# Transform.psm1
# 351: { Write-Error ($TransformMsgs.ResgenNotFound -F $Resgen) }
# 380: { Write-Error ($TransformMsgs.CreateResourceFileError -F $LastExitCode,$log) }
# 394: { Write-Error ($TransformMsgs.ResourceFileNotFound -F $SrcResx) }

Describe "Resgen" {
    It "does something useful" {
        $true | Should Be $false
    }
}
