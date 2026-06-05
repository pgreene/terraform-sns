output "names" {
  value = { for k, t in aws_sns_topic.general : k => t.name }
}

output "ids" {
  value = { for k, t in aws_sns_topic.general : k => t.id }
}

output "arns" {
  value = { for k, t in aws_sns_topic.general : k => t.arn }
}

output "subscription_arns" {
  value = { for k, s in aws_sns_topic_subscription.general : k => s.arn }
}

output "feedback_role_arn" {
  description = "ARN of the SNS delivery-status (feedback) IAM role, or null when not managed by this module"
  value       = local.create_feedback_role ? module.feedback_role[0].arn : null
}

# chatbot outputs, only populated when chatbot is enabled in the root module

output "chatbot_name" {
  value = local.create_chatbot ? one(aws_iam_role.chatbot[*].name) : null
}

output "chatbot_arn" {
  value = local.create_chatbot ? one(aws_iam_role.chatbot[*].arn) : null
}

output "chatbot_policy_name" {
  value = local.create_chatbot ? one(aws_iam_policy.chatbot[*].name) : null
}

output "chatbot_policy_arn" {
  value = local.create_chatbot ? one(aws_iam_policy.chatbot[*].arn) : null
}

output "chat_configuration_arn" {
  value = local.create_chatbot ? one(aws_chatbot_slack_channel_configuration.general[*].chat_configuration_arn) : null
}

output "slack_channel_name" {
  value = local.create_chatbot ? one(aws_chatbot_slack_channel_configuration.general[*].slack_channel_name) : null
}

output "slack_team_name" {
  value = local.create_chatbot ? one(aws_chatbot_slack_channel_configuration.general[*].slack_team_name) : null
}
