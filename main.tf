module "opensearch" {
  source            = "./modules"
  domain_name       = var.domain_name
  region            = var.region
  engine_version    = var.engine_version
  instance_type     = var.instance_type
  volume_type       = var.volume_type 
  volume_size       = var.volume_size
  master_nodes      = var.master_nodes_needed ? var.master_nodes : 0
  worker_nodes      = var.worker_nodes_needed ? var.worker_nodes : 0
  tags              = var.tags
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  slack_webhook_url = var.slack_webhook_url  # Pass Slack webhook URL to the module
}
output "opensearch_domain_id" {
  description = "The ID of the OpenSearch domain."
  value       = module.opensearch.opensearch_domain_id
}

output "opensearch_endpoint" {
  description = "The endpoint URL of the OpenSearch domain."
  value       = module.opensearch.opensearch_endpoint
}
#########################################################################################################################################

resource "aws_iam_service_linked_role" "opensearch_slr" {
  aws_service_name = "es.amazonaws.com"
  description      = "Service-Linked Role for Amazon OpenSearch Service"
}