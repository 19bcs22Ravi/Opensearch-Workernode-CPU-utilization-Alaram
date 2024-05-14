# module/output.tf

output "opensearch_domain_id" {
  description = "The ID of the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.id
}

output "opensearch_endpoint" {
  description = "The endpoint URL of the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.endpoint
}
