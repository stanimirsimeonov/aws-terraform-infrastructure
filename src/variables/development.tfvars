region           = "eu-west-2"
profile          = "tbc-profile"
domain           = "dev.tbchealthcare.co.uk"
K8S_NAME         = "tbc-application"
K8S_NAMESPACES   = ["development-tbc-marketing", "development-tbc-portal"]
ECR_REPOSITORIES = [
  "basephp-cli",
  "basephp-fpm",
  "development-tbc-marketing/fpm",
  "development-tbc-marketing/cli",
  "development-tbc-marketing/nginx",
  "development-tbc-portal/fpm",
  "development-tbc-portal/cli",
  "development-tbc-portal/nginx"
]
K8S_APPLICATIONS = {
  development-tbc-marketing = "tbc-marketing",
  development-tbc-portal    = "tbc-portal",
}

K8S_APPLICATION-BUCKETS = {
  development-tbc-marketing = "tbchealthcare-marketing",
  development-tbc-portal    = "tbchealthcare-portal",
}

RDS_DATABASES = [
  {
    instance_class        = "db.t4g.micro"
    namespace             = "development-tbc-marketing"
    application           = "tbc-marketing-application"
    identifier            = "tbc-marketing-development"
    db_name               = "tbc_marketing"
    allocated_storage     = 10
    max_allocated_storage = 15
    multi_az              = false
  },
  {
    instance_class        = "db.t4g.small"
    namespace             = "development-tbc-portal"
    application           = "tbc-portal-application"
    identifier            = "tbc-application-development"
    db_name               = "tbc_application"
    allocated_storage     = 20
    max_allocated_storage = 25
    multi_az              = false
  },
]

REDIS_INSTANCES = [
  {
    name            = "development"
    service-name    = "redis-development"
    num_cache_nodes = 1
    port            = 6379
    instance_class  = "cache.t2.micro"
  }
]