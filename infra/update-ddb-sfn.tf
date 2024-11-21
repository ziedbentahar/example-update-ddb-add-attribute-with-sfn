
resource "aws_iam_role" "state_machine" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "state_machine" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          data.aws_dynamodb_table.table_to_update.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state_machine" {
  role       = aws_iam_role.state_machine.name
  policy_arn = aws_iam_policy.state_machine.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  role_arn = aws_iam_role.state_machine.arn

  definition = templatefile("${path.module}/update-ddb-state.tpltf", {
    TableName        = data.aws_dynamodb_table.table_to_update.name,
    KeyAttributeName = var.table_to_update.key_attribute_name,
    TTLAttribute     = "expire_at"
  })
}
