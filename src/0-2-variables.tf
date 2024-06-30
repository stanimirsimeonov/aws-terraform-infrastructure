variable "region" {
  description = "Which AWS account has been chosen for deploying the infra."
  type        = string
}

variable "domain" {
  description = "Which domain has been used in the cluster for the deployed services"
  type        = string
}

variable "profile" {
  description = "Which AWS profile has been used for exchanging credentials between the application and the host TTY"
  type        = string
  nullable    = true
}
variable "K8S_NAME" {
  description = "Which EKS name that we will be working with"
  type        = string
}

variable "ECR_REPOSITORIES" {
  description = "What repository we want to push"
  type        = list
}

variable "K8S_NAMESPACES" {
  type    = list
}

variable "K8S_APPLICATIONS" {
  type    = map
}

variable "K8S_APPLICATION-BUCKETS" {
  type    = map
}

variable "RDS_DATABASES" {
  type = list(object(
    {
      allocated_storage     = number
      namespace             = string
      max_allocated_storage = number
      application           = string
      identifier            = string
      instance_class        = string
      multi_az              = bool
      db_name               = string
    }
  ))

}

variable "REDIS_INSTANCES" {
  type = list(object(
    {
      name            = string
      #      namespace       = string
      service-name    = string
      instance_class  = string
      num_cache_nodes = number
      port            = number
    }
  ))

}