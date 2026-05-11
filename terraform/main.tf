provider "aws" {
    region = "ap-south-1"
 
}

resource "aws_sns_topic" "jarvis_devops_bot_topic" {
    name = "jarvis-devops-bot-topic"
}


resource "aws_iam_role" "lambda_role"{
    name = "jarvis_lambda_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "telegram_alert" {
    function_name = "jarvis_telegram_alert"
    filename = "lambda.zip"
    role = aws_iam_role.lambda_role.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.12"
    source_code_hash = filebase64sha256("lambda.zip")

    environment {
        variables = {
            BOT_TOKEN = "7821396786:AAE7lS4DF4sYS6xFhKmQcfK6CTeuGvrf-OU"
            CHAT_ID = "8215126479"
        }
    }
}

resource "aws_lambda_permission" "allow_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.telegram_alert.function_name
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.jarvis_devops_bot_topic.arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
    topic_arn = aws_sns_topic.jarvis_devops_bot_topic.arn
    protocol = "lambda"
    endpoint = aws_lambda_function.telegram_alert.arn
}

resource "aws_cloudwatch_metric_alarm" "high_CPU" {
   alarm_name = "high_CPU"
   comparison_operator = "GreaterThanOrEqualToThreshold"
   evaluation_periods = "2"
   metric_name = "CPUUtilization"
   namespace = "AWS/EC2"
   period = "120"
   statistic = "Average"
   threshold = "1"
   alarm_description = "This metric monitors high CPU utilization"
   dimensions = {
     InstanceId = "i-0bd63e52fa7fe0820"
   }

   alarm_actions = [aws_sns_topic.jarvis_devops_bot_topic.arn] 
}