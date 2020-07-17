provider "aws" {
  version = "2.59"
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
}

# resource "aws_key_pair" "jenkins_key" {
#   public_key = "${file("/home/tuubayalcin/.ssh/id_rsa.pub")}"
#   key_name   = "cluster"
# }

resource "aws_instance" "jenkins" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
  # key_name      = "${aws_key_pair.jenkins_key.key_name}"
  tags = {
    Name = "Jenkins"
  }
}


  # resource "aws_instance" "jenkins" {
  #   ami           = "ami-08f3d892de259504d"
  #   instance_type = "t2.micro"
  #   tags = {
  #     Name = "Jenkins"
  #   }
  # }
  