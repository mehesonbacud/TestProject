#!/bin/bash
# Prepare variables and tmp directory
if [[ "$1" == "" ]];
then 
  echo "Enter Solution name: "
  read SOLUTION_NAME
else 
  SOLUTION_NAME=$1
fi
if [[ "$2" == "" ]];
then 
  echo "Enter Project name: "
  read PROJECT_NAME
else 
  PROJECT_NAME=$2
fi
if [[ "$3" == "" ]];
then
  echo "Enter CI/CD Strategy: (<Automatic>,<Approval>) "
  read CIRCLECI_STRATEGY
else
  CIRCLECI_STRATEGY=$3
fi
CURRENT_DIR=$PWD
TMP_DIR=/tmp/

# Apply ci/cd pipeline strategy
rm -f .circleci/config.yml

if [ "$CIRCLECI_STRATEGY" = "Approval" ]
then
    mv .circleci/config-approval.yml .circleci/config.yml
    rm -f .circleci/config-automatic.yml
else
    mv .circleci/config-automatic.yml .circleci/config.yml
    rm -f .circleci/config-approval.yml
fi

# Replace Project and Solution Names in CircleCi config
CIRCLECI_PRINCIPAL_ACCOUNT_TAG=CIRCLECICONFIGPRINCIPALACCOUNT
CIRCLECI_PROJECT_NAME_TAG=CIRCLECIPROJECTNAME
CIRCLECI_SOLUTION_NAME_TAG=CIRCLECISOLUTIONNAME
SOLUTION_NAME_UPPERCASE=${SOLUTION_NAME^^}
SOLUTION_NAME_LOWERCASE=${SOLUTION_NAME,,}

sed -i "s/$CIRCLECI_PRINCIPAL_ACCOUNT_TAG/$SOLUTION_NAME_UPPERCASE/g" .circleci/config.yml
sed -i "s/$CIRCLECI_PROJECT_NAME_TAG/$PROJECT_NAME/g" .circleci/config.yml
sed -i "s/$CIRCLECI_SOLUTION_NAME_TAG/$SOLUTION_NAME_LOWERCASE/g" .circleci/config.yml

# Create required Cloud set up
if [[ "$4" == "" ]];
then
  echo "Enter Cloud Provider: (<Azure>)"
  read CLOUD_PROVIDER
else
  CLOUD_PROVIDER=$4
fi

if [ "$CLOUD_PROVIDER" = "Azure" ]
then
  ./azuresetup.sh
fi
rm -f ./azuresetup.sh
rm -f ./azureadminrolesassignment.sh
rm -R ./ARMTemplates
rm -R ./docs

# Apply template
dotnet new --install .
dotnet new sln -n $SOLUTION_NAME -o "$TMP_DIR/$SOLUTION_NAME" --force
dotnet new broadsign-fsharpapp -n $PROJECT_NAME -o $TMP_DIR/$SOLUTION_NAME
dotnet sln $TMP_DIR/$SOLUTION_NAME/$SOLUTION_NAME.sln add $TMP_DIR/$SOLUTION_NAME/$PROJECT_NAME/$PROJECT_NAME.fsproj
dotnet build $TMP_DIR/$SOLUTION_NAME/$SOLUTION_NAME.sln
dotnet new -u "$CURRENT_DIR"

# Copy created solution
shopt -s extglob
rm -vrf !(init.sh)
find . -type d -name '.[^.]*' -not -path './.git' -prune -not -path './.circleci' -prune -exec rm -rf {} +
cp -rf $TMP_DIR/$SOLUTION_NAME/* "$CURRENT_DIR"
rm -rf $TMP_DIR/$SOLUTION_NAME