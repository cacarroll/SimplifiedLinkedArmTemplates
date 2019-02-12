param(
    [string]
    $DeploymentName,

    [string]
    $TemplateFile,

    [string]
    $TemplateParameterFile,

    [string]
    $TemplateContainerName,

    [string]
    $StorageAccountName,

    [string]
    $LinkedTemplatePath,

    [string]
    $Location,

    [switch]
    $Debug
)

$AzureStorageAccountParam = @{
    Name = $StorageAccountName
    ResourceGroupName = $StorageResourceGroupName
}

$StorageAccount = Get-AzureRmStorageAccount @AzureStorageAccountParam

if ($null -eq $StorageAccount)
{
    Throw "Unable to find StorageAccount $StorageAccountName"
}

$SasTokenparam = @{
    Context = $StorageAccount.Context
    Containter = $TemplateContainerName
    Permission = 'rl'
    ExpiryTime = (Get-Date).AddHours(1)
}

$TemplateSAStoken = New-AzureStorageContainerSASToken @SasTokenparam

if ($null -eq $TemplateSAStoken)
{
    Throw "Unable to create SAS Token for container $TemplateContainerName"
}

$DeploymentParam = @{
    ResourceGroupName = $DeploymentName
    StorageContainerName = $DeploymentName.ToLower()
    TemplatePath = $LinkedTemplatePath
    TemplateFile = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    TemplateSAStoken = $TemplateSAStoken
    ServerAdminPassword = $TestVmCredentials.Password
    ErrorAction = Stop 5>&1
}

if ($Debug)
{
    $debugpreference = 'Continue'

    $rawResponse = Test-AzureRmResourceGroupDeployment $DeploymentParam

    $debugpreference = 'SilentlyContinue'

    return $rawResponse
}
else
{
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

    $DeploymentParam.Add('Location',$Location)

    New-AzureRmResourceGroupDeployment @DeploymentParam
}

