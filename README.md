# Microservices template
The microservice fsharp template.

## Requirements
The project requires the following to be installed on your machine:
* .NET Core 6.0 ([download](https://dotnet.microsoft.com/download/dotnet-core))

## Technologies used
* `F#`
* `.Net Core`
* `Terraform`

## Set up a new Service
* Create a new repository in GitHub from template `ap-fsharp-template`.
* Checkout new repository locally
* In the `terminal`, go to the root directory of the solution and run the following command
  * For windows/linux/mac using a linux bash tool, update permission of init.sh by `chmod +x init.sh`, then run
    `./init.sh` or `./init.sh [Solution name] [Project name] [CI/CD Strategy: (<Automatic>,<Approval>)] [Cloud Provider: (<Azure>)]`
* Define a CI/CD Pipeline deployment strategy (See CircleCI).
* Commit and push changes
* Set up az-service-account Context Environment Variables (%_SERVICE_APP_ID, %_SERVICE_APP_PASSWORD):
  * az-service-account-labs
  * az-service-account-preview
  * az-service-account-cloud
* Request Admins to execute the Role Assignment script to Cloud Provider on JIRA (Script to be used -> `azureadminrolesassigment.sh`)
* Set up new project using included config in CircleCI

## Run the application
In `Rider`, click `arrow`(run) or `bug`(debug) on the top right corner
* If the project does not run in Development environment check the `Run/Debug configurations` on the left of `arrow`

or
in command line execute the following commands in the base path.
`dotnet build`
`dotnet run`

## Terraform organisation
Folder: /Terraform
* main.tf: configures the resources that make up your infrastructure.
* providers.tf: declares cloud provider to deploy and credentials
* variables.tf: declares input variables for your dev and prod environment prefixes, and the AWS region to deploy to.
* terraform.tfvars: defines your region and environment prefixes. Terraform automatically loads variable values from any files that end in .tfvars
* outputs.tf: specifies the website endpoints for your dev and prod buckets.
* assets: houses your webapp HTML file.
* `<template>.tf`: Azure Resources Templates in the cloud provider. Please, check below available resources.

Azure Resources
* app-service
* application-insights
* log-analytic-workspace
  
Azure Data Sources
* resource-group

## Terraform Commands
* `terraform init`: command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.
  (https://www.terraform.io/cli/commands/init)
    * This project is based on using Backend: https://www.terraform.io/language/settings/backends/configuration
    * Backend file name: backend.hcl
    * Storage Account for Backend: tfstateeu, tfstateeuuat, tfstatenaci > missingbillschdrport depending on the environment
* `terraform plan`: command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure
  (https://www.terraform.io/cli/commands/plan)
* `terraform apply`: command executes the actions proposed in a Terraform plan
  (https://www.terraform.io/cli/commands/apply)
* `terraform destroy`: DO NOT USE!!! command is a convenient way to destroy all remote objects managed by a particular Terraform configuration. It can cause platform deletes, try avoiding its use.  
  (https://www.terraform.io/cli/commands/destroy)

## CircleCI
* .circleci/config.yml (Mocked for Template)
* .circleci/config-automatic.yml
* .circleci/config-approval.yml
* Terraform Orb Documentation
https://circleci.com/developer/orbs/orb/circleci/terraform
* `Deployment strategy`:
  * Automatic Based Pipeline: Application will be deployed automatically to production environment. Any change will be promoted to Cloud environment automatically.
  ![docs/Automatic Based Pipeline.PNG](docs/Automatic Based Pipeline.PNG)
  * Approval Based Pipeline: Application will be deployed into Development environment. Promote to UAT and Production will require an approval.
  ![docs/Approval Based Pipeline.PNG](docs/Approval Based Pipeline.PNG)


## Azure Cloud naming convention
[Resource Type]-[Workload/Application]-[Environment]-[Region]-[Instance]
* Resource Type: E.g. as (App Service) af (App Function) sa (Storage Account)
* Workload/Application: Resource name. E.g. fsharptemplate
* Environment: E.g. labs, preview, cloud
* Region: Region abbreviation. E.g. na, eu, ap
* Instance: Number of instance. E.g. 01,02

(https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
