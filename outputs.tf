output "function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.logs.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "lambda_qualified_arn" {
  value = aws_lambda_function.lambda.qualified_arn
}