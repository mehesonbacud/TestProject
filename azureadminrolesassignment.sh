#!/bin/bash
# Prepare variables and tmp directory
if [[ "$1" == "" ]];
then
  echo "Enter Principal Account Cloud. E.g. PA-fsharptemplate-cloud: "
  read PA_ACCOUNT_CLOUD
else
  PA_ACCOUNT_CLOUD=$1
fi

if [[ "$2" == "" ]];
then
  echo "Environment: (<labs>,<preview>,<cloud>,<all>)"
  read ADMIN_ENVIRONMENT_NAME
else
  ADMIN_ENVIRONMENT_NAME=$2
fi

# Build all script variables from cloud principal account
PRINCIPAL_ACCOUNT_PREFIX="PA-"
PRINCIPAL_ACCOUNT_SUFFIX_LABS="-labs"
PRINCIPAL_ACCOUNT_SUFFIX_PREVIEW="-preview"
PRINCIPAL_ACCOUNT_SUFFIX_CLOUD="-cloud"
AZ_ROOT_NAME_TMP=${PA_ACCOUNT_CLOUD#$PRINCIPAL_ACCOUNT_PREFIX}
AZ_ROOT_NAME=${AZ_ROOT_NAME_TMP%$PRINCIPAL_ACCOUNT_SUFFIX_CLOUD}

# Login with your admin account
echo "Logging into Azure..."
az login > /dev/null 2>&1
echo "Logged."

# Labs and Preview config
az account set --subscription "Ayuda Preview" > /dev/null 2>&1
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Config variables
RESOURCE_GROUP_NAME_PREFIX="rg-"
RESOURCE_GROUP_NAME_SUFFIX_LABS="-labs-na-01"
RESOURCE_GROUP_NAME_SUFFIX_PREVIEW="-preview-eu-01"

# Assign roles labs principal
RESOURCE_GROUP_LABS="$RESOURCE_GROUP_NAME_PREFIX$AZ_ROOT_NAME$RESOURCE_GROUP_NAME_SUFFIX_LABS"
PRINCIPAL_ACCOUNT_LABS="$PRINCIPAL_ACCOUNT_PREFIX$AZ_ROOT_NAME$PRINCIPAL_ACCOUNT_SUFFIX_LABS"
PRINCIPAL_ACCOUNT_LABS_OBJ_ID=$(az ad sp list --display-name $PRINCIPAL_ACCOUNT_LABS --query [].id --output tsv)

if [[ "$ADMIN_ENVIRONMENT_NAME" == "labs" || "$ADMIN_ENVIRONMENT_NAME" == "all" ]];
then
echo "Assigning roles for Labs."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_LABS_OBJ_ID --role "Contributor" --resource-group $RESOURCE_GROUP_LABS)
echo "Contributor Role assignment command executed for RG $RESOURCE_GROUP_LABS."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_LABS_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\tfstatenaci\\providers\\Microsoft.Storage\\storageAccounts\\tfstatenaci)
echo "Contributor Role assignment command executed for Terraform StorageAccount tfstatenaci."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_LABS_OBJ_ID --role "Reader" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\rg-broadsign-labs-na-01\\providers\\Microsoft.Web\\serverFarms\\sp-broadsign-linux-labs-na-01)
echo "Reader Role assignment command executed for App Service Plan sp-broadsign-linux-labs-na-01."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_LABS_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourcegroups\\ayudapreview-eu-01\\providers\\Microsoft.ManagedIdentity\\userAssignedIdentities\\Circleci-Terraform-ACR-pull-EU-UAT)
echo "Contributor Role assignment command executed for UAI Circleci-Terraform-ACR-pull-EU-UAT."
echo "Roles assignment process for Labs finished."
fi
# Assign roles preview principal
RESOURCE_GROUP_PREVIEW="$RESOURCE_GROUP_NAME_PREFIX$AZ_ROOT_NAME$RESOURCE_GROUP_NAME_SUFFIX_PREVIEW"
PRINCIPAL_ACCOUNT_PREVIEW="$PRINCIPAL_ACCOUNT_PREFIX$AZ_ROOT_NAME$PRINCIPAL_ACCOUNT_SUFFIX_PREVIEW"
PRINCIPAL_ACCOUNT_PREVIEW_OBJ_ID=$(az ad sp list --display-name $PRINCIPAL_ACCOUNT_PREVIEW --query [].id --output tsv)

if [[ "$ADMIN_ENVIRONMENT_NAME" == "preview" || "$ADMIN_ENVIRONMENT_NAME" == "all" ]];
then
echo "Assigning roles for Preview."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_PREVIEW_OBJ_ID --role "Contributor" --resource-group $RESOURCE_GROUP_PREVIEW)
echo "Contributor Role assignment command executed for RG $RESOURCE_GROUP_PREVIEW."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_PREVIEW_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\tfstateeuuat\\providers\\Microsoft.Storage\\storageAccounts\\tfstateeuuat)
echo "Contributor Role assignment command executed for Terraform StorageAccount tfstateeuuat."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_PREVIEW_OBJ_ID --role "Reader" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\rg-broadsign-preview-eu-01\\providers\\Microsoft.Web\\serverFarms\\sp-broadsign-linux-preview-eu-01)
echo "Reader Role assignment command executed for App Service Plan sp-broadsign-linux-preview-eu-01."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_PREVIEW_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourcegroups\\ayudapreview-eu-01\\providers\\Microsoft.ManagedIdentity\\userAssignedIdentities\\Circleci-Terraform-ACR-pull-EU-UAT)
echo "Contributor Role assignment command executed for UAI Circleci-Terraform-ACR-pull-EU-UAT."
echo "Roles assignment process for Preview finished."
fi

# Cloud config
az account set --subscription "Ayuda Cloud"  > /dev/null 2>&1
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Config variables
RESOURCE_GROUP_NAME_SUFFIX_CLOUD="-cloud-eu-01"
RESOURCE_GROUP_NAME_LOCATION_CLOUD="northeurope"

# Assign roles cloud principal
RESOURCE_GROUP_CLOUD="$RESOURCE_GROUP_NAME_PREFIX$AZ_ROOT_NAME$RESOURCE_GROUP_NAME_SUFFIX_CLOUD"
PRINCIPAL_ACCOUNT_CLOUD="$PA_ACCOUNT_CLOUD"
PRINCIPAL_ACCOUNT_CLOUD_OBJ_ID=$(az ad sp list --display-name $PRINCIPAL_ACCOUNT_CLOUD --query [].id --output tsv)

# Create cloud infra
# Engineers does not have permissions to create Resource Groups in Cloud
if [[ "$ADMIN_ENVIRONMENT_NAME" == "cloud" || "$ADMIN_ENVIRONMENT_NAME" == "all" ]];
then
az group create -l $RESOURCE_GROUP_NAME_LOCATION_CLOUD -n $RESOURCE_GROUP_CLOUD > /dev/null 2>&1
echo "$RESOURCE_GROUP_CLOUD Created."

echo "Assigning roles for Cloud."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_CLOUD_OBJ_ID --role "Contributor" --resource-group $RESOURCE_GROUP_CLOUD)
echo "Contributor Role assignment command executed for RG $RESOURCE_GROUP_CLOUD."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_CLOUD_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\tfstateeu\\providers\\Microsoft.Storage\\storageAccounts\\tfstateeucloud)
echo "Contributor Role assignment command executed for Terraform StorageAccount tfstateeucloud."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_CLOUD_OBJ_ID --role "Reader" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourceGroups\\rg-broadsign-cloud-eu-01\\providers\\Microsoft.Web\\serverFarms\\sp-broadsign-linux-cloud-eu-01)
echo "Reader Role assignment command executed for App Service Plan sp-broadsign-linux-cloud-eu-01."
RESULT_AZ_COMMAND=$(az role assignment create --assignee $PRINCIPAL_ACCOUNT_CLOUD_OBJ_ID --role "Contributor" --scope \\subscriptions\\$SUBSCRIPTION_ID\\resourcegroups\\ayudacloud-eu-01\\providers\\Microsoft.ManagedIdentity\\userAssignedIdentities\\Circleci-Terraform-ACR-pull-EU)
echo "Contributor Role assignment command executed for UAI Circleci-Terraform-ACR-pull-EU."
echo "Roles assignment process for Cloud finished."
fi