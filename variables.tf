variable "access_key" { 
  description = "AWS access key"
}

variable "secret_key" { 
  description = "AWS secret access key"
}

variable "public_key_path" {
  description = "Path to the SSH public key"
}

variable "region" {
  description = "AWS region to host your Server"
  default = "us-east-1"
}


variable "aws_ami" {
  default = {
    us-east-1 = "ami-2051294a"
    us-west-2 = "ami-775e4f16"
  }
}
