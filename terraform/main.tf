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
    private_subnet_3_id  = module.vpc.private_subnet_3_id
    private_subnet_4_id  = module.vpc.private_subnet_4_id
    db_security_group_id = module.vpc.db_security_group_id

    db_name              = var.db_name
    db_username          = var.db_username
    db_password          = var.db_password
}

module "acm" {
    source             = "./modules/acm"
    depends_on         = [ module.vpc ]
    domain_name        = var.domain_name
    my_domain_name     = var.my_domain_name
}

module "ecs" {
    source                    = "./modules/ecs"

    depends_on                = [ module.vpc, module.rds, module.acm ]
    region                    = var.region
    environment               = var.environment
    vpc_id                    = module.vpc.vpc_id
    public_subnet_1_id        = module.vpc.public_subnet_1_id
    public_subnet_2_id        = module.vpc.public_subnet_2_id
    private_subnet_1_id       = module.vpc.private_subnet_1_id
    private_subnet_2_id       = module.vpc.private_subnet_2_id
    ecs_security_group_id     = module.vpc.ecs_security_group_id

    acm_certificate_arn       = module.acm.acm_certificate_arn
    image_name                = var.image_name
    image_version             = var.image_version
    container_port            = var.container_port
    host_port                 = var.host_port

    container_env_vars_config = <<EOF
        "environment" : [
            {"name": "DB_HOST", "value": "${module.rds.db_endpoint}"},
            {"name": "DB_USER", "value": "${var.db_username}"},
            {"name": "DB_PASSWORD", "value": "${var.db_password}"},
            {"name": "DB_NAME", "value": "${var.db_name}"}
        ],
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

module "route53" {
    source          = "./modules/route53"

    depends_on      = [ module.ecs, module.acm ]
    domain_name     = var.domain_name
    my_domain_name  = var.my_domain_name
    route53_zone_id = module.acm.route53_zone_id
    alb_dns_name    = module.ecs.alb_dns_addr
    alb_zone_id     = module.ecs.alb_zone_id 
}
