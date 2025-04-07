### Project Variables###
variable "project_name" {
  type = string
}

variable "environmen" {
  type = string
  default = "dev"
}

variable "common_tags" {
  type = map

}

#### VPC Variables####
variable "vpc_cidr" {

  type = string
  default = "10.0.0.0/16"
}

variable "vpc_tags" {
 type = map
  default = {}
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

##IGW Variables#####
variable "igw_tags" {
  type = map
  default = {}
}

# public Subnets Variables
variable "public_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "please enter valid 2 subnet cidrs"
  }
}

variable "public_subnet_cidr_tags" {
  type = map
  default = {}
}

# private Subnets Variables
variable "private_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "please enter valid 2 subnet cidrs"
  }
}

variable "private_subnet_cidr_tags" {
  type = map
  default = {}
}

# database Subnets Variables
variable "database_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "please enter valid 2 subnet cidrs"
  }
}

variable "database_subnet_cidr_tags" {
  type = map
  default = {}
}

# NAT Tags Variable
variable "nat_tags" {
  type = map
  default = {}
}

#Route Table Variables
variable "public_rt_tags" {
  default = {}
}

#Route Table Variables
variable "private_rt_tags" {
  default = {}
}

#Route Table Variables
variable "database_rt_tags" {
  default = {}
}

variable "aws_db_subnet_group_tags" {
  default = {}
}

#peering Variables
variable "is_peering_required" {
  type = bool
  default = false
}

variable "acceptor_vpc_id" {
  type = string
  default = ""
}

variable "vpc_peering_tags" {
  default = {}
}
