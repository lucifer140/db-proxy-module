variable "role-name" {
type = string
default = ""
}


variable "policy-name" {
  type = string
  default = ""
}


variable "db_proxy-name" {
    type = string
    default = ""
  
}


variable "sg-id" {
    type = string
    default = ""
  
}



variable "debug_logging" {
    type = string
    default = ""
  
}

variable "engine_family" {
    type = string
    default = ""
  
}

variable "idle_client_timeout" {
    type = string
    default = ""
  
}

variable "require_tls" {
    type = string
    default = ""
  
}

variable "connection_borrow_timeout" {
    type = string
    default = ""
  
}

variable "max_connections_percent" {
    type = string
    default = ""
  
}

variable "max_idle_connections_percent" {
    type = string
    default = ""
  
}

variable "rds_cluster_identifier" {
    type = string
    default = ""
  
}

variable "vpc_subnet_ids" {
    type = List(string)
    default = ""
  
}
variable "db_username" {
  type = string
  default = ""
  
}

variable "password" {
  type = string
  default = ""


  
}

variable "engine" {
  type = string
  default = ""
  
}

variable "host" {
  type = string
  default = ""
  
}

variable "port" {
  type = string
  default = ""
  
}

variable "db_cluster_identifier" {
  type = string
  default = ""
}

