variable "cluster_name"       { type = string }
variable "cluster_version"    { type = string }        # e.g. "1.31"
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "instance_type"      { type = string }         # t3.small
variable "min_size"           { type = number }
variable "max_size"           { type = number }
variable "desired_size"       { type = number }