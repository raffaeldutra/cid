# Cloud Front
# @function: AWSCloudfrontListAllById
# @description: Lista as distribuições do Cloud Front
# @noargs
# @return: List<String>
# @exitcode 0 Sucesso
function AWSCloudfrontListAllById() {
  aws cloudfront list-distributions \
  --query "DistributionList.Items[*].Origins.Items[*].Id" \
  --output text
}
