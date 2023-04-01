source ${CLI_FULL_PATH}/tests/tests.sh

function TestAllFunctions() {

  # # Terraform
  TestTerraformShowInstalledVersions
  TestTerraformInitCommand
  TestTerraformGetCurrentWorkspace
  TestTerraformSetVersion

  # Amazon
  TestAWSGetCredentials

  TestAWSGetCredentialsAccessKey
  TestAWSGetCredentialsAccessKeyId
  TestAWSGetCredentialsCreateEnvVariableAccessKeyId
  TestAWSGetCredentialsCreateEnvVariableAccessKey

  # CloudFront
  TestAWSCloudfrontListAllById

  # # API Gateway
  TestAWSApiGatewayGetAll
  TestAWSApiGatewayGetRestAPIs
  TestAWSApiGatewayGetResources
  # # TestAWSApiGatewayGetResourcesIntegrationRequests

  # # Secrets Manager
  TestAWSSecretsManagerListAll
  TestAWSSecretsManagerListByName
  TestAWSSecretsManagerListByTag
  TestAWSSecretsManagerDeleteForced

  # # EKS Kubernetes
  TestAWSEKSGenerateAuths
  TestAWSEKSGetClusters
  TestAWSEKSGetAmountClusters
  TestAWSEKSGetNodeGroupsByCluster
  TestAWSEKSDescribeNodeGroupsByCluster
  TestAWSEKSGetNodeGroupsInfos
  TestAWSEKSGetAmountNodes
  TestAWSEKSGetAmountNodeGroups
  TestAWSEKSGetClusterVersion
  TestAWSEKSListNodeGroupsNamesByCluster
  TestAWSEKSListNodesPerLabel
  # TestKubernetesListTopPodsBy

  # # Lambda
  TestAWSLambdaListFunctions
  TestAWSLambdaInvokeFunction

  # # Docker
  TestDockerIsThisDocker

  # # Git
  TestGitGetCurrentBranch

  # # Helpers
  TestHelperGetPasswordArgoCD
  TestHelperGetPasswordGrafana
  TestHelperGetPasswordDashboard

  # # Kubernetes
  TestKubernetesSetCurrentCluster
  TestKubernetesGetCurrentCluster
  TestKubernetesSetCurrentNamespace
  TestKubernetesGetCurrentNamespace

  # OS
  # TestOSCreateSSHKeys
  TestOsGetFreeMemory
  TestOsGetTime
  TestOsGetTimeUTC
  TestOsCompareUTCWithBrazilianTime
  TestOsIsChristmasWeek
  TestOsPermissionSanitization
  TestOsPermissionForFilesSanitization
  TestOsPermissionForDirectoriesSanitization

  # # RabbitMQ
  # TestRabbitMQHelp
  # TestRabbitMQCheckEnvironmentVariables
  # TestRabbitMQImportDefinitions
  # TestRabbitMQGetUsers
  # TestRabbitMQGetMessages
  # TestRabbitMQGetExtensions
  # TestRabbitMQGetDefinitions

}
