data "aws_ecr_repository" "service" {
    name = "${var.environment}-ecr"
}