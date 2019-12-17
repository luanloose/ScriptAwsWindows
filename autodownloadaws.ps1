#======================================! Sobre o Script !=====================================#
# SCRIPT   : autodownloadaws.sp1: Download AWS S3 images Windows Version.
# AUTOR    : Luan A. Loose
# DATA     : 16/01/2019
#===================================! Controle de Versoes !===================================#
# Versao 1.0 - Luan A. Loose - 16-01-2019 | Criado Script para download automatico de imagens				
#---------------------------------------------------------------------------------------------#


$aws_access_key = ""
$aws_secret_key = ""

#========================== Atributos configuraveis ===========================#

# Regiao associada ao bucket que o rad ira usar
$region = "us-east-1"

# Bucket que melhor atente o RADIOLOGISTA
$bucket = "rtransfer"

# Nome da pasta do RADIOLOGISTA na AWS
$aws_folder = "ESCRITORIO/"

# Local para importar os arquivos
$localPath = "C:\Users\Luan\Desktop\Teste\Arquivos\"    

#------------------------------------------------------------------------------#


WriteLog -Message "--------------Start--------------"

while(true){

# Pegara todos objetos da pasta do rad e jogara dentro da variavel
$objects = Get-S3Object -BucketName $bucket -KeyPrefix $aws_folder -AccessKey $aws_access_key -SecretKey $aws_secret_key -Region $region

# loop que copiara objeto por objeto e salvara na pasta

if(!$objects)
    {
        WriteLog -Message "This folder $aws_folder is blank"
    }
    else
    {
        foreach($object in $objects) {
            $localFileName = $object.Key -replace $aws_folder, ''
            if ($localFileName -ne '') {
                $localFilePath = Join-Path $localPath $localFileName
                Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $aws_access_key -SecretKey $aws_secret_key -Region $region
            }
        }
     }

WriteLog -Message "--------------Complete--------------"
}