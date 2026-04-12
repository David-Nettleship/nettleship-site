data "aws_iam_policy_document" "lambda_auth_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda_auth" {
  name               = "nettleship-site-lambda-auth"
  assume_role_policy = data.aws_iam_policy_document.lambda_auth_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_auth_basic_execution" {
  role       = aws_iam_role.lambda_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_ssm_parameter" "site_auth" {
  name = "/nettleship/site/auth-password"
}

# Render the template and zip it — password is pulled from SSM at plan time
data "archive_file" "auth_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda/auth.zip"

  source {
    content  = templatefile("${path.module}/lambda/auth.js.tpl", { password = data.aws_ssm_parameter.site_auth.value })
    filename = "index.js"
  }
}

# Lambda@Edge must be deployed in us-east-1
resource "aws_lambda_function" "auth" {
  provider         = aws.us_east_1
  function_name    = "nettleship-site-auth"
  filename         = data.archive_file.auth_lambda.output_path
  source_code_hash = data.archive_file.auth_lambda.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_auth.arn
  publish          = true # Lambda@Edge requires a numbered version, not $LATEST
}
