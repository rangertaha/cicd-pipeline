
variable "region" {
  type = string
  default = "us-east-2"
}

variable "release" {
  type = string
  default = "0.0.1"
}

variable "project" {
  type = string
  default = "jenkins"
}

variable "security_group" {
  default = "jenkins_sg"
}

variable "whitelisted_web" {
  default = ["0.0.0.0/0"]
}

variable "whitelisted_ssh" {
  default = ["0.0.0.0/0"]
}

