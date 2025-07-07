variable "bucket_name" {
    type = string
    default = "rsoon-resume.com"
}

variable "domain_name" {
  type    = string
  default = "rsoon-resume.com"   
}

resource "aws_s3_bucket" "s3" {
    bucket = var.bucket_name
    provider = aws
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
        type = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.s3.arn}/*"]

    # Allows the action only when the request's source arn equals that of this cf distributon
    condition {
        test = "StringEquals"
        variable = "AWS:SourceArn" 
        values = [aws_cloudfront_distribution.s3_distribution.arn]
        }
    }
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "cert" {
  domain_name  = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "domain" {
  name = var.domain_name
}

# Create DNS record for each domain in the ACM cert using the name and value from ACM
resource "aws_route53_record" "dnsrecord" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
    allow_overwrite = true
    name = each.value.name
    records = [each.value.record]
    ttl = 60
    type  = each.value.type
    zone_id = data.aws_route53_zone.domain.zone_id
    }


resource "aws_cloudfront_origin_access_control" "s3_secure" {
  name                              = "s3_secure"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# Create CloudFront distribution with S3 origin
locals {
  s3_origin_id = "myS3Origin"
}

# origin_id is the label for origin block
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_secure.id
    origin_id                = local.s3_origin_id # label for origin block
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
        }
    }

    viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
    }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
    }

  price_class = "PriceClass_200"

  tags = {
    Environment = "production"
    }

  restrictions {
    geo_restriction {
    restriction_type = "none" 
    locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    }
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "cloudresume-visitor-counter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "counter_id"

  attribute {
    name = "counter_id"
    type = "N"
  }
}

resource "aws_dynamodb_table_item" "item" {
  table_name     = aws_dynamodb_table.dynamodb_table.name
  hash_key       = aws_dynamodb_table.dynamodb_table.hash_key

  item = jsonencode ({
  counter_id     = {"N": "1"}
  visitor_count  = {"N": "0"}
  })
}

data "archive_file" "lambda_zip" {  
  type = "zip"  
  source_file = "${path.module}/lambda_code/lambda_function.py" 
  output_path = "${path.module}/lambda_code/lambda_function.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "cloudresume-increment-visitor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.handler"
  runtime       = "python3.13"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_api_gateway_rest_api" "root" {
 name = "cloudresume-api"
 description = "API for cloud resume project. Endpoint is a lambda function"
}

resource "aws_api_gateway_resource" "root_child" {
  parent_id   = aws_api_gateway_rest_api.root.root_resource_id #this is root path lol
  path_part   = "{subpath+}"
  rest_api_id = aws_api_gateway_rest_api.root.id
}

#POST method execution path

resource "aws_api_gateway_method" "post_request" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.root_child.id
  rest_api_id   = aws_api_gateway_rest_api.root.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  resource_id = aws_api_gateway_resource.root_child.id
  http_method = aws_api_gateway_method.post_request.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda.invoke_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:us-east-1:193544298890:${aws_api_gateway_rest_api.root.id}/*/${aws_api_gateway_method.post_request.http_method}${aws_api_gateway_resource.root_child.path}"
}

resource "aws_api_gateway_method_response" "post_response" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  resource_id = aws_api_gateway_resource.root_child.id
  http_method = aws_api_gateway_method.post_request.http_method
  status_code = "200"

    #CORS
    response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  resource_id = aws_api_gateway_resource.root_child.id
  http_method = aws_api_gateway_method.post_request.http_method
  status_code = aws_api_gateway_method_response.post_response.status_code

  #CORS
    response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"  
  }

  depends_on = [
    aws_api_gateway_method.post_request,
    aws_api_gateway_integration.lambda_integration
    ] 
  }

  #OPTIONS method execution path

  resource "aws_api_gateway_method" "options_request" {
    rest_api_id = aws_api_gateway_rest_api.root.id
    resource_id = aws_api_gateway_resource.root_child.id
    http_method = "OPTIONS"
    authorization = "NONE"
  }

  resource "aws_api_gateway_integration" "integration_request" {
    rest_api_id = aws_api_gateway_rest_api.root.id
    resource_id = aws_api_gateway_resource.root_child.id
    http_method = aws_api_gateway_method.options_request.http_method
    integration_http_method = "OPTIONS"
    type = "MOCK"
  }

  resource "aws_api_gateway_method_response" "options_response" {
    rest_api_id = aws_api_gateway_rest_api.root.id
    resource_id = aws_api_gateway_resource.root_child.id
    http_method = aws_api_gateway_method.options_request.http_method
    status_code = "200"

    #CORS
    response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin" = true
    }
  }

  resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.root.id
    resource_id = aws_api_gateway_resource.root_child.id
    http_method = aws_api_gateway_method.options_request.http_method
    status_code = aws_api_gateway_method_response.options_response.status_code

    #CORS
    response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"  
    }

    depends_on = [
      aws_api_gateway_method.options_request,
      aws_api_gateway_integration.integration_request
    ]
  }

  resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id = aws_api_gateway_rest_api.root.id

    triggers = {
      #Manually force changes in deployment
      redeployment = sha1(jsonencode([
        aws_api_gateway_resource.root_child.id,
        aws_api_gateway_method.post_request.id,
        aws_api_gateway_integration.lambda_integration.id,
        aws_api_gateway_method.options_request.id,
        aws_api_gateway_integration.integration_request.id,
      ]))
    }

    lifecycle {
      create_before_destroy = true
      }
    }

  resource "aws_api_gateway_stage" "development_stage" {
    deployment_id = aws_api_gateway_deployment.deployment.id
    rest_api_id   = aws_api_gateway_rest_api.root.id
    stage_name    = "development"
  }




