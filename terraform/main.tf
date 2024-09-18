module "vpc" {
    source         = "./modules/vpc"

    environment    = var.environment
    region         = var.region
    container_port = var.container_port
    host_port      = var.host_port
}

module "rds" {
    source               = "./modules/rds"

    depends_on           = [ module.vpc ]
    environment          = var.environment
    region               = var.region 
    private_subnet_1_id  = module.vpc.private_subnet_1_id
    private_subnet_2_id  = module.vpc.private_subnet_2_id
    db_security_group_id = module.vpc.db_security_group_id

    db_name              = var.db_name
    username             = var.username
    password             = var.password
}

module "ecs" {
    source                    = "./modules/ecs"

    depends_on                = [ module.vpc, module.rds ]
    environment               = var.environment
    vpc_id                    = module.vpc.vpc_id
    public_subnet_1_id        = module.vpc.public_subnet_1_id
    public_subnet_2_id        = module.vpc.public_subnet_2_id
    private_subnet_1_id       = module.vpc.private_subnet_1_id
    private_subnet_2_id       = module.vpc.private_subnet_2_id
    ecs_security_group_id     = module.vpc.ecs_security_group_id

    container_name            = var.container_name
    image_name                = var.image_name
    container_port            = var.container_port
    host_port                 = var.host_port

    container_env_vars_config = <<EOF
        "environment" : [
            {"name": "DB_HOST", "value": "${module.rds.db_endpoint}"},
            {"name": "DB_USER", "value": "${var.username}"},
            {"name": "DB_PASSWORD", "value": "${var.password}"},
            {"name": "DB_NAME", "value": "${var.db_name}"}
        ]
    EOF
}

module "ec2" {
    source                     = "./modules/ec2"

    depends_on                 = [ module.vpc ]
    environment                = var.environment
    vpc_id                     = module.vpc.vpc_id
    public_subnet_1_id         = module.vpc.public_subnet_1_id
    public_subnet_2_id         = module.vpc.public_subnet_2_id
    bastion_security_group_id  = module.vpc.bastion_secuity_group_id
    key_name                   = var.key_name
}

