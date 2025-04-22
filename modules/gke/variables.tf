variable "project_id"   { type = string }
variable "region"       { type = string }
variable "environment"  { type = string }
variable "network"      { type = string }
variable "subnet"       { type = string }

variable "labels" {
  type    = map(string)
  default = {}
}