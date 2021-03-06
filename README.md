# Deploying Azure Resources using Linked Templates - Simplified

## __Table of Contents__

---

  - [Objectives](#objectives)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Testing Your Azure ARM Templates](#testing-your-azure-arm-templates)
  - [Deploy](#deploy)
  - [Parameters Json Schema](#parameters-json-schema)
  - [Example Paremeter Files](#example-paremeter-files)
  - [References](#references)

## __Objectives__

Provide a flexible and simplified method for deploying custom network, NIC and compute resources into Azure

## __Overview__

Azure Resource Manager is a consistent management layer that enables you to create, update, and delete resources in your Azure subscription.  However, adding resources, updating, or removing can be tricky due to the nature of JSON.  Also, testing ARM deployments can be challenging and time consuming.

These linked templates and simplified parameters JSON file allow for easy updates or additions to building out defined Azure networks, NICs and compute.

The linked templates support conditions so there is no need to create different ARM templates based on different deployment scenarios.  All that is necessary is to update the parameters file with your values.  An array of VM's is deployed using a defined configuration that is unique to each VM.

- Deploy generalized or specialized Windows or Linux operating systems
- Deploy networks with the ability to define subnets and address prefixes
- Set custom DNS server settings
- Define custom IP address for NICs
- Assign NICs to defined networks
- Support single or dual NIC computer resources
- Easily assign public IP addresses to compute
- Define the compute size for each specific VM in the array

## __Prerequisites__

1. Create a Storage Account, a Storage Container for the virtual network, NIC and compute templates, as well as a Storage Container for any specialized VHD images and storing the VHD(s) being created for the VM(s)
2. Copy the files in the LinkedTemplates folder to the Storage Container created in step 1
3. Modify the vhdStorageAccountUrl parameter in the parameter file to reflect the path to the VHD Storage Container created in step 1
4. Run Connect-AzureRmAccount to connect PowerShell to Azure

![StorageContainer](images/linkedtemplates.PNG)

## __Testing Your Azure ARM Templates__

This command will validate your ARM template, prior to production deployment.  It is important to do this to confirm there are no errors.  It will also provide valuable debugging information if there is a problem.

PowerShell

```PowerShell
.\deploy.ps1 -DeploymentName 'TestDeployment' -TemplateFile .\azure.json -TemplateParameterFile `
.\azure.parameters.json -TemplateContainerName '<NameOfContainer>' -StorageAccountName '<NameOfStorageAccount>' -LinkedTemplatePath '<URLToContainer>' -Debug
```

## __Deploy__

This command will deploy the resources to Azure, after any issues found during the debug process have been resolved.

PowerShell

```PowerShell
.\deploy.ps1 -DeploymentName 'Deployment' -TemplateFile .\azure.json -TemplateParameterFile `
.\azure.parameters.json -TemplateContainerName '<NameOfContainer>' -StorageAccountName '<NameOfStorageAccount>' -LinkedTemplatePath '<URLToContainer>'
```

## __Parameters JSON Schema__

**targetItemName:** Name assiged to the VM

**vhdUrl:** URL to the generalized/specialized VHD that will be used during the creation of the VM

**vmSize:** Compute size assigned to the VM

**osType:** The type of operating system of the VM (Windows or Linux)

**pip:** If a Public IP address will be assigned to the compute (true or false)

**networks:** Array or networks that will be assigned to the compute

**name:** Name assigned to the NIC

**IPAddress:** IP address assigned to the first NIC

**subnetName:** Subnet name of the NIC should be attached

## __Example Paremeter Files__

**multiDomainControllers** - Demonstrates how to deploy specialized VHDs to deploy two Domain Controllers

**syspreppedWindowsImage** - Demonstrates how to deploy two sysprepped Windows images

**sccmInfrastructure** - Demonstrates how to deploy Domain Controllers, SCCM Site Servers, and a test server with a public IP

## __References__

[Linked ARM Template Microsoft Docs Page](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates)
