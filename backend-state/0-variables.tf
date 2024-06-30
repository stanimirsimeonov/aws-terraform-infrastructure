variable "region" {
  description = "Which AWS account has been chosen for deploying the infra."
  type        = string
  default     = "eu-west-2"
}

variable "profile" {
  description = "Which AWS profile has been used for exchanging credentials between the application and the host TTY"
  type        = string
  default     = "tbc-profile"
  nullable = true
}
