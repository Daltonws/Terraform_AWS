provider "aws" {
    region = "us-east-2"

}
variable "ingressrules" {
  type = list(number)
  default = [80,443]
}
variable "egresserules" {
  type = list(number)
  default = [80,443]
}

resource "aws_instance" "DBServer" {
    ami = "ami-0a0ad6b70e61be944"
    instance_type = "t2.micro"
     security_groups = [aws_security_group.DBServerTraffic.name]
     tags = {
       "Name" = "DB Server"
     }
     user_data = "${file("install_apache.sh")}"
}

resource "aws_instance" "webserver" {
    ami = "ami-0a0ad6b70e61be944"
    instance_type = "t2.micro"
     security_groups = [aws_security_group.DBServerTraffic.name]
     tags = {
       "Name" = "Web Server"
     }
     user_data = "${file("install_apache.sh")}"
}
resource "aws_eip" "Web_EIP" {
    instance = aws_instance.webserver.id
}
    output "PublicIP" {
        value = aws_eip.Web_EIP.public_ip
    }
    output "PrivateIP" {
        value = aws_instance.DBServer.private_ip
      
    }
    resource "aws_security_group" "DBServerTraffic" {
  name = "Allow HTTPS"

 dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content{
    from_port = port.value
    to_port = port.value
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    }
  } 
    dynamic "egress" {
    iterator = port
    for_each = var.egresserules
   content{
    from_port = port.value
    to_port = port.value
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    }
    }
  } 