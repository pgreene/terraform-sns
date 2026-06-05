locals {
  # When a feedback role name is given, this module creates the SNS delivery-
  # status (feedback) IAM role and attaches it to every topic for HTTP success/
  # failure logging. Otherwise topics fall back to any caller-supplied ARNs.
  create_feedback_role = var.feedback_role_name != null

  http_success_feedback_role_arn = local.create_feedback_role ? module.feedback_role[0].arn : var.http_success_feedback_role_arn
  http_failure_feedback_role_arn = local.create_feedback_role ? module.feedback_role[0].arn : var.http_failure_feedback_role_arn

  # When a chatbot role name is given, this module creates the AWS Chatbot
  # (Slack) IAM role, policy, and channel configuration. Root modules that do
  # not need chatbot leave var.chatbot_name null and these resources are skipped.
  create_chatbot = var.chatbot_name != null

  # var.chatbot_topic names the topic routed to AWS Chatbot (Slack) instead of
  # the HTTPS/PagerDuty endpoint: it is excluded from the endpoint subscription
  # below and attached to the chatbot channel configuration. When null, every
  # topic gets the endpoint subscription.
  endpoint_topics = var.chatbot_topic != null ? setsubtract(var.topics, [var.chatbot_topic]) : var.topics
}

# SNS delivery-status (feedback) IAM role, formerly the standalone
# alarm-topics/sns-feedback-role unit. Reuses the iam-role composition so the
# topics and their feedback role live in one module / terragrunt unit / state.
module "feedback_role" {
  source = "../iam-role"
  count  = local.create_feedback_role ? 1 : 0

  name        = var.feedback_role_name
  policy_name = local.create_feedback_role ? "${var.feedback_role_name}-policy" : null

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = ["sns.amazonaws.com", "events.amazonaws.com"]
      }
      Action = "sts:AssumeRole"
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:PutMetricFilter",
        "logs:PutRetentionPolicy",
        "logs:Describe*",
        "logs:Get*",
        "logs:List*",
        "sns:*",
      ]
      Resource = "*"
    }]
  })

  tags = var.feedback_role_tags
}

resource "aws_sns_topic" "general" {
  for_each = var.topics

  name                                     = each.key
  display_name                             = var.display_name
  delivery_policy                          = var.delivery_policy
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn
  http_success_feedback_role_arn           = local.http_success_feedback_role_arn
  http_success_feedback_sample_rate        = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn           = local.http_failure_feedback_role_arn
  kms_master_key_id                        = var.kms_master_key_id
  signature_version                        = var.signature_version
  tracing_config                           = var.tracing_config
  fifo_topic                               = var.fifo_topic
  archive_policy                           = var.archive_policy
  content_based_deduplication              = var.content_based_deduplication
  lambda_success_feedback_role_arn         = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn         = var.lambda_failure_feedback_role_arn
  sqs_success_feedback_role_arn            = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn            = var.sqs_failure_feedback_role_arn
  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn
  tags                                     = var.tags
}

resource "aws_sns_topic_policy" "general" {
  for_each = var.topics

  arn    = aws_sns_topic.general[each.key].arn
  policy = var.policy != null ? var.policy : data.aws_iam_policy_document.sns_topic_policy[each.key].json
}

resource "aws_sns_topic_subscription" "general" {
  for_each = local.endpoint_topics

  topic_arn              = aws_sns_topic.general[each.key].arn
  protocol               = var.protocol
  endpoint               = var.endpoint
  endpoint_auto_confirms = var.endpoint_auto_confirms
  raw_message_delivery   = var.raw_message_delivery
}

# Only enable chatbot when needed in the root modules
# -----------------------------------------------------
resource "aws_iam_role" "chatbot" {
  count = local.create_chatbot ? 1 : 0

  name                  = var.chatbot_name
  description           = var.chatbot_description
  force_detach_policies = var.chatbot_force_detach_policies
  max_session_duration  = var.chatbot_max_session_duration
  path                  = var.chatbot_path
  permissions_boundary  = var.chatbot_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role_chatbot[0].json
  tags                  = var.tags
}

resource "aws_iam_policy" "chatbot" {
  count = local.create_chatbot ? 1 : 0

  name        = var.chatbot_policy_name
  path        = var.chatbot_policy_path
  description = var.chatbot_description
  policy      = data.aws_iam_policy_document.chatbot[0].json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  count = local.create_chatbot ? 1 : 0

  role       = aws_iam_role.chatbot[0].name
  policy_arn = aws_iam_policy.chatbot[0].arn
}

resource "aws_chatbot_slack_channel_configuration" "general" {
  count = local.create_chatbot ? 1 : 0

  configuration_name = var.configuration_name
  iam_role_arn       = aws_iam_role.chatbot[0].arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_team_id
  # When chatbot_topic is set, subscribe the config to that topic's ARN in this
  # region plus any cross-region slack-notify topic ARNs the caller supplies, so
  # a single (global) chatbot config can fan in topics from multiple regions.
  sns_topic_arns = var.chatbot_topic != null ? concat([aws_sns_topic.general[var.chatbot_topic].arn], var.chatbot_extra_sns_topic_arns) : var.sns_topic_arns
  tags           = var.tags
}

# -----------------------------------------------------
