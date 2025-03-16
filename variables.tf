variable "region" {
    description = "region of aws"  
    type = string
    default = "ap-south-1"
}
variable "data-of-web"{
  description = "data of website"
  type = list(string)
}