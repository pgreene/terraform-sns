data "aws_iam_policy_document" "sns_topic_policy" {
  for_each = var.topics

  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.general[each.key].arn,
    ]

    sid = "__default_statement_ID"
  }

  statement {
    sid    = "AllowCloudWatchAndEventBridgePublish"
    effect = "Allow"

    actions = ["SNS:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com",
      ]
    }

    resources = [
      aws_sns_topic.general[each.key].arn,
    ]
  }
}

# chatbot
data "aws_iam_policy_document" "chatbot" {
  count = local.create_chatbot ? 1 : 0

  statement {
    sid    = "chatbot"
    effect = "Allow"
    actions = [
      "cloudwatch:*",
      "ec2:*",
      "ecs:*",
      "logs:*",
      "rds:*",
      "sns:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_chatbot" {
  count = local.create_chatbot ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "chatbot.amazonaws.com"
      ]
    }
  }
}
