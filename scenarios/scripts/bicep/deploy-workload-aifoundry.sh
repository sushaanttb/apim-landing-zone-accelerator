#!/bin/bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -f "$script_dir/../../.env" ]]; then
	echo "Loading .env"
	source "$script_dir/../../.env"
fi

if [[ ${#ENABLE_TELEMETRY} -eq 0 ]]; then
  telemetry=true
fi

if [[ -f "$script_dir/../../apim-baseline/bicep/output.json" ]]; then
	echo "Loading baseline configuration"

    while IFS='=' read -r key value; do
        export "$key=${value//\"/}"
    done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' "$script_dir/../../apim-baseline/bicep/output.json")
else
    echo "ERROR: Missing baseline configuration. Run deploy-apim-baseline.sh" 1>&2
    exit 6
fi

cat << EOF > "$script_dir/../../workload-aifoundry/bicep/parameters.json"
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceSuffix" :{
        "value": "${resourceSuffix}"
    },
    "aiHubName" :{
        "value": "demo"
    },
    "aiHubProjectName" :{
        "value": "project"
    }

  }
}
EOF

deployment_name="workload-aifoundry-${RESOURCE_NAME_PREFIX}"

echo "$deployment_name"
cd "$script_dir/../../workload-aifoundry/bicep/"
echo "=="
echo "== Starting bicep deployment ${deployment_name}"
echo "=="
output=$(az deployment sub create \
  --template-file main.bicep \
  --name "$deployment_name" \
  --parameters parameters.json \
  --location "$AZURE_LOCATION" \
  --output json)

echo "== Completed bicep deployment ${deployment_name}"

echo "$output" | jq "[.properties.outputs | to_entries | .[] | {key:.key, value: .value.value}] | from_entries" > "$script_dir/../../workload-aifoundry/bicep/output.json"

aiHubName=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.aiHubName')
aiServicesId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.aiServicesId')
aiServicesTarget=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.aiServicesTarget')
applicationInsightsId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.applicationInsightsId')
containerRegistryId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.containerRegistryId')
keyVaultId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.keyVaultId')
storageAccountId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.storageAccountId')
projectId=$(cat "$script_dir/../../workload-aifoundry/bicep/output.json" | jq -r '.projectId')

echo "AI Hub: ${aiHubName} created successfully."
echo "AI Services: ${aiServicesId} created successfully."
echo "AI Services Target: ${aiServicesTarget} created successfully."
echo "Application Insights: ${applicationInsightsId} created successfully."
echo "Container Registry: ${containerRegistryId} created successfully."
echo "Key Vault: ${keyVaultId} created successfully."
echo "Storage Account: ${storageAccountId} created successfully."
echo "Project: ${projectId} created successfully."

echo -e "\n"