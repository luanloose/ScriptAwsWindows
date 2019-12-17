param([string]$user, [string]$bucket, [string]$dir)
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

Set-AWSCredentials -AccessKey key -SecretKey secretkey -StoreAs default
$localPath = "$(split-path -parent $MyInvocation.MyCommand.Definition)\"

$pUser=$user
$pBucket=$bucket
$pDir=$dir

$currentFilePath = [System.IO.Directory]::GetFiles($localPath, "autodownloadaws*")[0]
$currentFileName = [System.IO.Path]::GetFileName($currentFilePath)

   
$latestUpdate = Get-S3Object -BucketName powershell-updates -KeyPrefix autodownloadaws

if($latestUpdate.Key -ne $currentFileName)
{
    $locaFile = [System.IO.Path]::Combine($localPath, [System.IO.Path]::GetFileName($latestUpdate.Key))
    Copy-S3Object -BucketName  powershell-updates -Key $latestUpdate.Key -LocalFile $locaFile
    [System.IO.File]::Delete($currentFilePath)

    $currentFilePath = $locaFile
}

Invoke-Expression "&'$currentFilePath' -user $pUser -bucket $pBucket -dir $pDir"