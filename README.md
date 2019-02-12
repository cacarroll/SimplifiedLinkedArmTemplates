# Deploying Azure Resources using Linked Templates - Simplified!

# Table of Contents
- [Deploying Azure Resources using Linked Templates - Simplified!](#deploying-azure-resources-using-linked-templates---simplified)
- [Table of Contents](#table-of-contents)
- [Objectives](#objectives)
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Testing Your Azure ARM Templates](#testing-your-azure-arm-templates)
- [Deploy](#deploy)
- [Parameters Json Schema](#parameters-json-schema)
- [Example Paremeter Files](#example-paremeter-files)
- [References](#references)

<a name="objectives"></a>
# Objectives
Provide a flexible and simplified method for deploying custom compute, nics, and network resources into Azure

<a name="overview"></a>
# Overview
Azure Resource Manager is a consistent management layer that enables you to create, update, and delete resources in your Azure subscription.  However, adding resources, updating, or removing can be tricky due to the nature of json.  Also, testing ARM deployments can be challenging and time consuming.

These linked templates and simplified parameters json file allow for easy updates or additions to building out defined Azure compute, networks, nics.

The linked templates support conditions so there is no need to create different ARM templates based on different deployment scenarios.  All that is necessary is to update the parameters file with your values.  An array of VM's is deployed using a defined configuration that is unique to each VM.

- Deploy generalized or specialized Windows or Linux operating systems
- Deploy networks with the ability to define subnets and address prefixes
- Set custom DNS server settings
- Define custom IP address for Nics
- Assign nics to defined networks
- Support single or dual nic computer resources
- Esily assign public IP addresses to compute
- Define the compute size for each specific vm in the array

<a name="prerequisites"></a>
# Prerequisites
1. Create a storage account and container.
2. Copy the files under \LinkedTemplates to container created in step 1.
  ![alt text][linkedtemplates]

<a name="testing"></a>
# Testing Your Azure ARM Templates
The following will validate your ARM template prior to production deployment.  It is important to do this to confirm there are no errors.  It will also provide valuable debugging information if there a problem.

1. Open Powershell
2. deploy.ps1 -DeploymentName 'TestDeployment' -TemplateFile .\azure.json -TemplateParameterFile
.\azure.parameters.json -TemplateContainerName 'linkedtemplates' -StorageAccountName 'containerslabdiag' -LinkedTemplatePath 'https://containerslabdiag.blob.core.usgovcloudapi.net/linkedtemplates' -debug



<a name="deploy"></a>
# Deploy
1. Open PowerShell
2. deploy.ps1 -DeploymentName 'TestDeployment' -TemplateFile .\azure.json -TemplateParameterFile
.\azure.parameters.json -TemplateContainerName 'linkedtemplates' -StorageAccountName 'containerslabdiag' -LinkedTemplatePath 'https://containerslabdiag.blob.core.usgovcloudapi.net/linkedtemplates'

<a name="parameters"></a>
# Parameters Json Schema

**targetItemName:** Namne assiged to the VM.

**vhdUrl:** Url to the generalized/specialized vhd that will be used during the creation of the vm.

**vmSize:** Compute size assigned to the virtual machine.

**osType:** The type of Operating System of the VM. (Windows or Linux)

**pip:** True/False if a Public IP address will be assigned to the compute.

**networks:** Array or networks that will be assigned to the compute.

**name:** Name assigned to the nic

**IPAddress:** IP address assigned to the first nic

**SubnetName:** Subnet name of the Nic should be attached

<a name="Example Parameter Files"></a>
# Example Paremeter Files

**multiDomainControllers** - Demonstrates how to deploy specialized vhds to deploy two domain controllers.

**syspreppedWindowsImage** - Demonstrates how to deploy two sysprepped Windows images

**sccmInfrastructure** - Demonstrates how to deploy Domain Controllers, SCCM Site Servers, and a test server with a public IP.

<a name="references"></a>
# References
https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates


[linkedtemplates]: images/linkedtemplates.png "LinkedTemplates"