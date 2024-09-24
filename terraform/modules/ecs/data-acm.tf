data "aws_acm_certificate" "cert" {
    domain      = "pramodpro.xyz"
    most_recent = true
}
