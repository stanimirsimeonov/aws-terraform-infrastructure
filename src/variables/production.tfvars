region           = "eu-west-2"
profile          = "tbc-profile"
domain           = "tbchealthcare.co.uk"
K8S_NAME         = "tbc-application"

K8S_NAMESPACES   = ["production-tbc-marketing", "production-tbc-portal"]
ECR_REPOSITORIES = [
  "production-tbc-marketing/fpm",
  "production-tbc-marketing/cli",
  "production-tbc-marketing/nginx",
  "production-tbc-portal/fpm",
  "production-tbc-portal/cli",
  "production-tbc-portal/nginx"
]
K8S_APPLICATIONS = {
  production-tbc-marketing = "tbc-marketing",
  production-tbc-portal    = "tbc-portal",
}

K8S_APPLICATION-BUCKETS = {
  production-tbc-marketing = "tbchealthcare-marketing",
  production-tbc-portal    = "tbchealthcare-portal",
}

RDS_DATABASES = [
  {
    instance_class        = "db.t4g.micro"
    namespace             = "production-tbc-marketing"
    application           = "tbc-marketing-application"
    identifier            = "tbc-marketing-production"
    db_name               = "tbc_marketing"
    allocated_storage     = 10
    max_allocated_storage = 15
    multi_az              = false
  },

  {
    instance_class        = "db.m5.large"
    namespace             = "production-tbc-portal"
    application           = "tbc-portal-application"
    identifier            = "tbc-application-production"
    db_name               = "tbc_application"
    allocated_storage     = 20
    max_allocated_storage = 700
    multi_az              = true
  },
]

REDIS_INSTANCES = [
  {
    name            = "production"
    service-name    = "redis-production"
    num_cache_nodes = 1
    port            = 6379
    instance_class  = "cache.t4g.medium"
  },
]