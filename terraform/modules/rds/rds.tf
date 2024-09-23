resource "aws_db_subnet_group" "rds_subnet" {
    name       = "${var.environment}-rds-subnet"
    subnet_ids = [var.private_subnet_3_id,var.private_subnet_4_id]

    tags = {
        Name = "${var.environment}-rds-subnet"
    }
}

# resource "aws_rds_cluster_instance" "cluster_instance" {
#     identifier           = "${var.environment}-cluster-instance"
#     cluster_identifier   = aws_rds_cluster.db_cluster.id
#     engine               = "aurora-mysql"
#     engine_version       = "8.0"
#     instance_class       = "db.t3.medium"
#     db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
#     depends_on           = [aws_rds_cluster.db_cluster]
# }

# resource "aws_rds_cluster" "db_cluster" {
#     cluster_identifier      = "aurora-cluster-demo-1"
#     engine                  = "aurora-mysql"
#     engine_version          = "8.0"
#     availability_zones      = ["${var.region}a"]
#     database_name           = var.db_name
#     master_username         = var.db_username
#     master_password         = var.db_password

#     db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
#     vpc_security_group_ids  = [var.db_security_group_id]
#     skip_final_snapshot     = true
# }

resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier     = "${var.environment}-db-cluster"
    engine                 = "aurora-mysql"
    engine_mode            = "serverless"
    engine_version         = "5.7.mysql_aurora.2.11.4"
    port                   = "3306"
    database_name          = var.db_name
    master_username        = var.db_username
    master_password        = var.db_password
    enable_http_endpoint   = true
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
    vpc_security_group_ids = [var.db_security_group_id]
    scaling_configuration {
        min_capacity = 2
    }
}
