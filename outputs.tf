output "function_arn" {
  type  = string
  value = aws_lambda_function.lambda.arn
}

output "function_name" {
  type  = string
  value = aws_lambda_function.lambda.function_name
}

output "lambda_role_name" {
  type  = string
  value = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  type  = string
  value = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  type = string
  value = aws_cloudwatch_log_group.logs.name
}

output "log_group_arn" {
  type = string
  value = aws_cloudwatch_log_group.logs.arn
}