
variable "region" {
  description = "AWS Region"
  default     = null
}

variable "env_name" {
  description = "Environment Name"
  default     = null
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = null
}

variable "topics" {
  description = "Set of SNS topic names to create"
  type        = set(string)
  default     = []
}

variable "display_name" {
  default = null
}

variable "delivery_policy" {
  default = null
}

variable "application_success_feedback_role_arn" {
  default = null
}

variable "application_success_feedback_sample_rate" {
  default = null
}

variable "application_failure_feedback_role_arn" {
  default = null
}

variable "http_success_feedback_role_arn" {
  default = null
}

variable "http_success_feedback_sample_rate" {
  default = null
}

variable "http_failure_feedback_role_arn" {
  default = null
}

variable "kms_master_key_id" {
  default = null
}

variable "signature_version" {
  default = null
}

variable "tracing_config" {
  default = null
}

variable "fifo_topic" {
  default = null
}

variable "archive_policy" {
  default = null
}

variable "content_based_deduplication" {
  default = null
}

variable "lambda_success_feedback_role_arn" {
  default = null
}

variable "lambda_success_feedback_sample_rate" {
  default = null
}

variable "lambda_failure_feedback_role_arn" {
  default = null
}

variable "sqs_success_feedback_role_arn" {
  default = null
}

variable "sqs_success_feedback_sample_rate" {
  default = null
}

variable "sqs_failure_feedback_role_arn" {
  default = null
}

variable "firehose_success_feedback_role_arn" {
  default = null
}

variable "firehose_success_feedback_sample_rate" {
  default = null
}

variable "firehose_failure_feedback_role_arn" {
  default = null
}

variable "account_id" {
  default = null
}

variable "policy" {
  default = null
}

# SNS delivery-status (feedback) IAM role

variable "feedback_role_name" {
  description = "Name of the SNS delivery-status (feedback) IAM role to create and attach to every topic for HTTP delivery logging. When null, no role is created and the http_*_feedback_role_arn inputs are used as-is."
  default     = null
}

variable "feedback_role_tags" {
  type    = map(string)
  default = null
}

# SNS Topic Subscription

variable "topic_arn" {
  default = null
}

variable "endpoint" {
  default = null
}

variable "endpoint_auto_confirms" {
  default = true
}

variable "protocol" {
  description = "https, email, etc"
  default     = "https"
}

variable "raw_message_delivery" {
  default = "true"
}

# chatbot
variable "chatbot_name" {
  description = "For naming chatbot IAM Role"
  default     = null
}

variable "chatbot_policy_name" {
  description = "For naming chatbot IAM Policy"
  default     = null
}

variable "chatbot_description" {
  description = "(Optional) Description of the chatbot IAM role."
  default     = null
}

variable "chatbot_force_detach_policies" {
  description = "(Optional) Whether to force detaching any policies the role has before destroying it. Defaults to false."
  default     = null
}

variable "chatbot_max_session_duration" {
  description = "(Optional) Maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  default     = null
}

variable "chatbot_path" {
  description = "(Optional) Path to the chatbot IAM role. See IAM Identifiers for more information."
  default     = "/"
}

variable "chatbot_policy_path" {
  description = "(Optional) Path to the chatbot IAM policy. See IAM Identifiers for more information."
  default     = "/"
}

variable "chatbot_permissions_boundary" {
  description = "(Optional) ARN of the policy that is used to set the permissions boundary for the chatbot IAM role."
  default     = null
}

variable "configuration_name" {
  default = null
}

variable "slack_channel_id" {
  description = "Default value is the #server-monitoring channel id"
  default     = null
}

variable "slack_team_id" {
  default = null
}

variable "sns_topic_arns" {
  default = null
}

variable "chatbot_topic" {
  description = "Name of the topic (must be one of var.topics) routed to AWS Chatbot (Slack) instead of the HTTPS/PagerDuty endpoint. It is excluded from the endpoint subscription and attached to the chatbot channel configuration. When null, every topic gets the endpoint subscription and sns_topic_arns is used as-is."
  default     = null
}

variable "chatbot_extra_sns_topic_arns" {
  description = "Additional SNS topic ARNs (e.g. the same-named topic from other regions) to attach to the chatbot channel configuration alongside this region's chatbot_topic. Lets one global chatbot config receive notifications from topics in multiple regions. Ignored when chatbot_topic is null."
  type        = list(string)
  default     = []
}
