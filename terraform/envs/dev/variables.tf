variable "region" { type = string }
variable "cluster_name" { type = string }         # used next step
variable "name" { type = string }                 # name prefix for resources
variable "vpc_cidr" { type = string }             # e.g. 10.0.0.0/16
variable "azs" { type = list(string) }            # e.g. ["us-east-1a","us-east-1b"]
variable "public_subnets" { type = list(string) } # e.g. ["10.0.1.0/24","10.0.2.0/24"]
variable "private_subnets" { type = list(string) }

variable "cluster_version" { type = string }
variable "instance_type"   { type = string }
variable "min_size"        { type = number }
variable "max_size"        { type = number }
variable "desired_size"    { type = number }

variable "repository_name" { type = string }