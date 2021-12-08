terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}

resource "aws_cloudformation_stack" "network" {
  name = "myezbrew-stack"
  parameters = {
    InternalALBDNSName = "alb-380867874.us-west-2.elb.amazonaws.com"
    ALBListenerPort = ""
    CWMetricFlagIPCount = "True"
    InvocationBeforeDeregistration = "3"
    MAXDNSLookupPerInvocation = "50"
    NLBTargetGroupARN = "arn:aws:elasticloadbalancing:us-west-2:932030202108:loadbalancer/net/nlb/f053d0a3243cfbc4"
    S3BucketName = aws_s3_bucket.lambda_bucket.id
    SameVPC = "True"
    Region = "us-west-2"
  }
  template_body = file("./cftemplates/template_poplulate_NLB_TG_with_ALB_python3.json")
  capabilities = ["CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
}
