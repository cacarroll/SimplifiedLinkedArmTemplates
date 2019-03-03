<#
.SYNOPSIS
    Tests or deploys environments using linked ARM Templates

.DESCRIPTION
    This script uses virtual network, NIC and compute ARM Templates stored in a preexisting Storage Container, a parameter template and a main template, along with either
    Test-AzureRmResourceGroupDeployment or New-AzureRmResourceGroupDeployment, to either test deploying the linked ARM Templates or deploy the linked ARM Templates.

.PARAMETER DeploymentName
    The name of the deployment, which will be the name of the Resource Group and the VHD Storage Container of the test or deployment being executed

.PARAMETER TemplateFile
    Fed by the parameter template and the PowerShell parameters being passed to Test-AzureRmResourceGroupDeployment or New-AzureRmResourceGroupDeployment, this is the template
    being used to feed parameters to the virtual network, NIC and compute templates

.PARAMETER TemplateParameterFile
    The template used to feed parameters, not defined by the PowerShell parameters being passed to Test-AzureRmResourceGroupDeployment or New-AzureRmResourceGroupDeployment, to
    the main template, which is defined in the TemplateFile parameter

.PARAMETER TemplateContainerName
    The name of the Storage Container where the linked ARM Templates are stored for testing and/or deployment (This used to create the SAS Token used to access the virtual network,
    NIC and compute templates)

.PARAMETER StorageAccountName
    The name of the Storage Account being used to store the virtual network, NIC and compute templates

.PARAMETER StorageAccountResourceGroupName
    The Resource Group Name of the Storage Account being used to store the virtual network, NIC and compute templates

.PARAMETER LinkedTemplatePath
    The URI to the Storage Container where the virtual network, NIC and compute templates are being stored (This is used to create the base for the virtual network, NIC and
    compute template TemplateUri variables set in the main template)

.PARAMETER Debug
    The switch used to determine whether a linked ARM Template deployment is being tested or deployed to Azure
#>
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
    $StorageAccountResourceGroupName,

    [string]
    $LinkedTemplatePath,

    [switch]
    $Debug
)

$resourceGroup = Get-AzureRmResourceGroup -Name $DeploymentName -ErrorAction SilentlyContinue
if ($null -eq $resourceGroup)
{
    $location = Read-Host -Prompt "There is no Resource Group with the name $DeploymentName, in the current subscription.  Please provide the location for the new Resource Group"
    New-AzureRmResourceGroup -Name $DeploymentName -Location $location
}

$azureStorageAccountParam = @{
    Name = $StorageAccountName
    ResourceGroupName = $StorageAccountResourceGroupName
}

$storageAccount = Get-AzureRmStorageAccount @azureStorageAccountParam

if ($null -eq $storageAccount)
{
    Throw "Unable to find StorageAccount $StorageAccountName"
}

$SasTokenparam = @{
    Context = $storageAccount.Context
    Container = $TemplateContainerName
    Permission = 'rl'
    ExpiryTime = (Get-Date).AddHours(1)
}

$templateSAStoken = New-AzureStorageContainerSASToken @SasTokenparam

if ($null -eq $templateSAStoken)
{
    Throw "Unable to create SAS Token for container $TemplateContainerName"
}

$DeploymentParam = @{
    ResourceGroupName = $DeploymentName
    StorageContainerName = $DeploymentName.ToLower()
    TemplatePath = $LinkedTemplatePath
    TemplateFile = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    TemplateSAStoken = $templateSAStoken
    ServerAdminPassword = ConvertTo-SecureString -String (Read-Host -Prompt 'Please enter the admin password for the VM(s) being created' -AsSecureString) -AsPlainText -Force
    ErrorAction = 'Stop'
}

if ($Debug -eq $true)
{
    $debugpreference = 'Continue'

    $rawResponse = Test-AzureRmResourceGroupDeployment @DeploymentParam 5>&1

    $debugpreference = 'SilentlyContinue'

    return $rawResponse
}
else
{
    New-AzureRmResourceGroupDeployment @DeploymentParam -Verbose
}
