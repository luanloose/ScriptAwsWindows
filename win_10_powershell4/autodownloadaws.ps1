param([string]$user, [string]$bucket, [string]$dir)
Add-Type -AssemblyName System.IO.Compression.FileSystem

Set-AWSCredentials -AccessKey key -SecretKey secretkey -StoreAs default
 
$logfile = "$(split-path -parent $MyInvocation.MyCommand.Definition)\$(gc env:computername)Transfer.log"

$pUser=$user
$pBucket=$bucket
$pDir=$dir

Function WriteLog 
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
  
    write-output $Line
}

Function ValidateParam 
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [string]
    $Param,
    [Parameter(Mandatory=$True)]
    [string]
    $Message
    )
    if ([string]::IsNullOrEmpty($Param)) 
    { 
        WriteLog -Level "ERROR" -Message "$Message, exiting script!"
        exit
    }
}

Function GetFiles()
{
    $files = Get-S3Object -BucketName $pBucket -Key $pUser
    if(!$files)
    {
        WriteLog -Message "There are no files to import."
    }
    else
    {
        foreach($file in $files) 
        {
            $locaFile = [System.IO.Path]::Combine($pDir, [System.IO.Path]::GetFileName($file.Key))
            WriteLog -Message "Transfering: $locaFile"
            curl "https://connectrad.com/services/imagesimport/?message=Downloading%20$file" > $null
            Copy-S3Object -BucketName $pBucket -Key $file.Key -LocalFile $locaFile
            UnzipFile -zipfile $locaFile
            [System.IO.File]::Delete($locaFile)
            Remove-S3Object -BucketName $pBucket -Key $file.Key -Force:$true > $null
        }
    }
}

Function UnzipFile()
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $zipfile
    )
    $outpath = [System.IO.Path]::Combine($pDir, [System.IO.Path]::GetFileNameWithoutExtension($zipfile))
    if([System.IO.Directory]::Exists($outpath))
    {
         WriteLog -Level WARN -Message "Directory already exist: $outpath"
    }
    else
    {
        [System.IO.Directory]::CreateDirectory($outpath)
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
        WriteLog -Message "Files saved to: $outpath"
    }
   
}

WriteLog -Message "--------------Starting--------------"

ValidateParam -Param $pUser -Message "User Login is blank"
ValidateParam -Param $pBucket -Message "AWS Bucket is blank"
ValidateParam -Param $pDir -Message "Directory is blank" 

if(![System.IO.Directory]::Exists($pDir))
{
    WriteLog -Level ERROR -Message "$pDir is not exist, exiting script!"
    exit
}

curl "https://connectrad.com/services/imagesimport/?message=Start%20$pUser" > $null

WriteLog -Message "Runing"
WriteLog -Message "User: $pUser"
WriteLog -Message "Bucket: $pBucket"
WriteLog -Message "Local Directory: $pDir"

GetFiles

curl "https://connectrad.com/services/imagesimport/?message=End%20$pUser" > $null

WriteLog -Message "--------------Complete--------------"
