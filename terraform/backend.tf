terraform {
    backend "s3" {
        bucket = "pramod858tf"
        key    = "terraform/php-web-app/terraform.tfstate"
        region = "us-east-1"
    }
}
